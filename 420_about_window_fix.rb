# 「mikutterについて」でrubyw.exe 0.2.2についてなどと表示されるのを修正
class Plugin::Settings
  alias :about_org :about

  def about(label, options={})
    if options[:name] && !options[:program_name]
      options[:program_name] = options[:name]
    end

    about_org(label, options)
  end
end
