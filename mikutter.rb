class Mikutter < Formula
  homepage "http://mikutter.hachune.net/"
  url "http://mikutter.hachune.net/bin/mikutter.3.2.3.tar.gz"
  sha256 "7e4337d38a4a778dc001c5d9a315ef3f9646eec3c386e9686abc7f58a9e5f8f5"

  # Require ruby 1.9.3 or above
  depends_on "ruby" if /\d\.\d(\.\d)?/.match(`ruby --version 2>&1`).to_s < "1.9.3"
  depends_on "gtk+"
  depends_on :x11

  def install
    prefix.install Dir["./*"]
    prefix.cd do
      ENV["GEM_HOME"] = "#{Pathname.pwd}/gems"
      unless /true/ =~ `gem list --installed bundler` && /bundle/ =~ `which bundle`
        system "gem", "install", "bundler", "--no-ri", "--no-rdoc"
        ENV.prepend_path "PATH", "#{ENV["GEM_HOME"]}/bin"
      end
      system "bundle", "config", "--local", "build.nokogiri", "--",
          "--use-system-libraries",
          "--with-xml2-include=\"$(xcrun --show-sdk-path)/usr/include/libxml2\""
      system "bundle", "install"
    end
    open("mikutter.sh", "w+") do |script|
      script.puts "#!/bin/sh"
      script.puts "export GEM_HOME=#{ENV["GEM_HOME"]}"
      script.puts "ruby \"#{prefix}/mikutter.rb\" $@"
    end
    bin.install "mikutter.sh" => "mikutter"
  end

  test do
    # Test without running X11
    system "mikutter", "--help"

    # Test whether the GUI/X11 will launch completely
	### NOTE: This test can't work fine. ###
    #system "mikutter", "-d"
    #sleep 20 # waiting for mikutter to launch
    #system "pkill", "-f", "mikutter"
  end
end
