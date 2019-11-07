require 'openssl'
require 'zlib'
require 'securerandom'

module AionS3

  # A <code>Packer</code> is a utility for packing and unpacking data.
  # Packing applies compression and encryption to provided data.
  # Unpacking applies decryption and decompression to provided data.
  #
  # Encryption uses cipher +AES-256-CBC+. The key is generated via a password provided when the <code>Packer</code> is initialized.
  # The password must be a string at least 20 chars long.
  #
  # It is *very* important that the password is randomly generated.
  class Packer

    # @return [String]
    attr_reader :password

    # Returns a new Packer object with a key based on the given +password+.
    # If no password is provided, a random password will be generated
    # The password can later be read via #password.
    #
    # @param [String] password
    def initialize(password = nil)
      password ||= Packer.random_password
      if password and password.size < 32
        raise ArgumentError, 'Provided password must be at least 32 characters'
      end
      @key = OpenSSL::Digest.digest('sha256', password)
      @password = password.freeze
    end

    # Encrypts data with +AES-256-CBC+ and returns it as a binary encoded string.
    #
    # @param [String] data
    # @return [String] a binary encoded string
    def encrypt(data)
      _data = data
      cipher = OpenSSL::Cipher::AES.new(256, :cbc).encrypt
      cipher.key = @key
      cipher.random_iv + cipher.update(_data) + cipher.final
    end

    # Decrypts data that have been encrypted using #encrypt(data) and returns it as a binary encoded string.
    #
    # @param [String] data
    # @return [String] a binary encoded string
    def decrypt(data)
      _data = data
      decipher = OpenSSL::Cipher::AES.new(256, :cbc).decrypt
      decipher.key = @key
      decipher.iv = _data.byteslice(0,16)
      decipher.update(_data.byteslice(16, _data.bytesize - 16)) + decipher.final
    end

    # Decompresses data with zlib and returns it a binary encoded string.
    #
    # @param [String] data
    # @return [String] a binary encoded string
    def deflate(data)
      Zlib::Deflate.deflate(data, Zlib::BEST_COMPRESSION)
    end

    # Compresses data with zlib and returns it a binary encoded string.
    #
    # @param [String] data
    # @return [String] a binary encoded string
    def inflate(data)
      Zlib::Inflate.inflate(data)
    end

    # Compresses and encrypts given data.
    #
    # *Note*
    # The ruby string's local encoding will be lost when packed.
    # unpack(data) will always return a string with binary encoding.
    #
    # Example:
    #
    #   data = 'æøå'  # utf8 encoded string
    #   str = unpack(pack(data))
    #
    #   puts str.bytes == data.bytes
    #   puts str == data
    #   puts str.encoding == data.encoding
    #
    # Produces:
    #
    #   true
    #   false
    #   false
    #
    # @param [String] data
    # @return [String] a binary encoded string
    def pack(data)
      encrypt(deflate(data))
    end

    # Decrypts and decompresses given data.
    #
    # @param [Object] data
    # @return [String] a binary encoded string
    def unpack(data)
      inflate(decrypt(data))
    end

    # Returns a base64 encoded string based on random bytes.
    # The length will be <code>n * 2</code> characters.
    #
    # If +n+ is not defined, it will default to 24, which will generate a 32 character base64 encoded string.
    #
    # @param [Integer] n
    # @return [String] a base64 encoded string
    def self.random_password(n = 24)
      SecureRandom.base64(n)
    end

  end
end
