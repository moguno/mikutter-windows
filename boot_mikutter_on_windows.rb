# -*- coding: utf-8 -*-

require File.join(File.absolute_path(File.dirname(__FILE__)), "common.rb")

apply_patches("boot")

Kernel.load File.join(mikutter_dir, "mikutter.rb")
