#coding: UTF-8

require 'rubygems'
require 'net/https'
require 'yaml'
require 'zlib'
require 'archive/tar/minitar'
require 'ostruct'

module Packaged
end

module Packaged::Common
  extend self

  # specファイルの内容について、扱いやすいように値を加工する
  def spec_normalization(spec)
    spec = YAML.load(spec) if spec.is_a? String
    spec["slug".freeze] = spec["slug".freeze].to_sym
    spec
  end

  # リストビューのカラムを使いやすくするクラス
  class ColumnHelper

    # コンストラクタ
    def initialize
      @columns = {}
      @index = 0
    end

    # カラム情報を登録
    def add(symbol, data)
      struct = OpenStruct.new(data)
      struct.index = @index
      struct.freeze

      @columns[symbol] = struct

      @index += 1
    end

    # カラム情報を参照
    def [](symbol)
      @columns[symbol]
    end

    # 値をカラム順に格納したファイルを作る
    def make_values(hash)
      values = @columns.map { |_| "" }

      hash.each { |k, v|
        values[@columns[k].index] = v
      }

      values
    end

     # Enumerable用
    def each(&block)
      @columns.values.each { |_| block.call(_) }
    end

    include Enumerable
  end
end

module Packaged::GUI
  extend self

  def error_box(parent, message)
    dialog = Gtk::MessageDialog.new(parent, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::ERROR, Gtk::MessageDialog::BUTTONS_OK, message)
    dialog.run
    dialog.destroy
  end
end

module Packaged::Local
  extend self

  PLUGIN_DIR = File::expand_path("~/.mikutter/plugin")

  # ローカルのファイルシステムからSPECファイルを取得する
  def get_spec(dir)
    result = nil

    [".mikutter.yml", "spec"].each { |path|
      file = File.join(dir, path)

      if File.file?(file)
        yaml_str = File.open(file) { |fp|
          fp.read
        }

        result = Packaged::Common::spec_normalization(yaml_str)
        break
      end
    }

    result
  end

 # tarボールを展開するぞなもし
  def extract_tgz(tgz_string, dest_dir)
    root_dir = nil

    tgz = StringIO.new(tgz_string)

    Zlib::GzipReader.wrap(tgz) { |tar|
      Archive::Tar::Minitar::unpack(tar, dest_dir) { |status, file|
        if !root_dir && (status == :dir)
          root_dir = file
        end
      }
    }

    root_dir
  end

  # tarボールをプラグインディレクトリにええ感じにインストールする
  def install_plugin_by_tgz(tgz_string, plugin_dir = PLUGIN_DIR, &block)
    if File.exist?(plugin_dir)
      FileUtils.mkdir_p(plugin_dir)
    end

    root_dir = extract_tgz(tgz_string, plugin_dir)

    extracted_dir = File.join(plugin_dir, root_dir)

    spec = Packaged::Local::get_spec(extracted_dir)

    if block
      block.call(extracted_dir, plugin_dir)
    else
      FileUtils.mv(extracted_dir, File.join(plugin_dir, spec["slug"].to_s))
    end
  end

  # インストールされたプラグインの情報を取得する
  def get_plugin_info_by_slug(slug)
    get_plugins.find { |_|
      if _[:status] != :unmanaged
        _[:spec]["slug"] == slug.to_sym
      else
        _[:dir] == slug
      end
    }
  end

  # インストールされたプラグインの情報を取得する
  def get_plugin_info_by_dir(dir, plugin_dir = PLUGIN_DIR)
    result = {}

    result[:dir] = dir
    result[:spec] = Packaged::Local::get_spec(File.join(plugin_dir, dir))

    # specファイルが無い -> 管理外ってことにする
    result[:status] = if result[:spec] == nil
      :unmanaged
    else
      # ディレクトリ名とslugが同じ -> 有効
      if result[:spec]["slug"] == dir.to_sym
        :enabled
      else
        :disabled
      end
    end

    result
  end

  # インストールされたプラグインのリストを取得する
  def get_plugins(plugin_dir = PLUGIN_DIR)
    Dir.chdir(plugin_dir) {
      Dir.glob("*").select { |_| FileTest.directory?(_) }.map { |dir|
        get_plugin_info_by_dir(dir, plugin_dir)
      }
    }
  end

  # プラグインを無効化する
  def disable_plugin(slug, plugin_dir = PLUGIN_DIR)
    target = get_plugins.find { |_| _[:spec] && (_[:spec]["slug"] == slug.to_sym) }

    if !target
      raise "プラグインが見つかりません"
    end

    if target[:status] != :enabled
      raise "プラグインは有効ではありません"
    end

    FileUtils.mv(File.join(plugin_dir, target[:dir]), File.join(plugin_dir, "__disabled__#{target[:dir]}"))
  end

  # プラグインを有効化する
  def enable_plugin(slug, plugin_dir = PLUGIN_DIR)
    target = get_plugins.find { |_| _[:spec] && (_[:spec]["slug"] == slug.to_sym) }

    if !target
      raise "プラグインが見つかりません"
    end

    if target[:status] != :disabled
      raise "プラグインは無効ではありません"
    end

    FileUtils.mv(File.join(plugin_dir, target[:dir]), File.join(plugin_dir, target[:spec]["slug"].to_s))
  end
end

module Packaged::Remote
  extend self

  # 例外
  class RemoteException < StandardError
    attr_reader :obj

    def initialize(obj)
      @obj = obj
    end

    def message
      if @obj.respond_to?(:inspect)
        @obj.inspect
      else
        @obj.to_s
      end
    end
  end

  # 生ファイルを要求する
  def query_raw_file(url_str, limit = 3)
    puts url_str

    if limit == 0
      raise RemoteException.new("redirect limit exceeded")
    end

    response = Net::HTTP::get_response(URI.parse(url_str))

    case response
    # 成功
    when Net::HTTPSuccess
      response.body
    # リダイレクト
    when Net::HTTPRedirection
      query_raw_file(response["location"], limit - 1)
    else
      raise RemoteException.new(response)
    end
  end

  # YAMLを要求する
  def query(url_str)
    yaml = query_raw_file(url_str)

    if yaml
      YAML.load(yaml)
    else
      nil
    end
  end

  # GitHubからリポジトリの一覧を得る
  def get_repos(user_name)
    query("https://api.github.com/users/#{user_name}/repos?per_page=100")
  end

  # 多分mikutterプラグインのリポジトリを選別する
  def get_maybe_mikutter_repos(user_name)
    repos = get_repos(user_name)

    if repos
      repos.select { |_| _["name"].to_s =~ /mikutter/i }
    else
      []
    end
  end

  # GitHubのタグを得る
  def get_tags(user_name, repo_name)
    query("https://api.github.com/repos/#{user_name}/#{repo_name}/tags")
  end

  # GitHubからファイルを取得する
  def get_file(user_name, repo_name, tag, path)
    query_raw_file("https://raw.githubusercontent.com/#{user_name}/#{repo_name}/#{tag}/#{path}")
  end

  # リポジトリのtarボールを取得する
  def get_repo_tarball(user_name, repo_name, tag)
    query_raw_file("https://api.github.com/repos/#{user_name}/#{repo_name}/tarball/#{tag}")
  end

  # プラグインの情報を得る
  def get_plugin_info(user_name, repo_name)
    result = {}

    result[:repo_name] = repo_name
    result[:spec] = Packaged::Remote::get_spec(user_name, repo_name)

    local_info = Packaged::Local::get_plugin_info_by_slug(result[:spec]["slug"])

    result[:status] = if local_info
      :installed
    else
      :not_installed
    end

    result
  end

  # GitHubからSPECファイルを取得する
  def get_spec(user_name, repo_name)
    result = nil

    [".mikutter.yml", "spec"].each { |path|
      begin
        result = Packaged::Common::spec_normalization(get_file(user_name, repo_name, "master", path))
        break
      rescue
        # 例外は無視
      end
    }

    if !result
      raise RemoteException.new("spec file is not found")
    end

    result
  end
end
