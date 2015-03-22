#coding: utf-8

# OpenSSLの証明書がアレなので、証明書の検証をすっ飛ばすよ。
# DNSが汚染されてたらがっかりですね。
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
