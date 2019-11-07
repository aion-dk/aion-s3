# encoding: UTF-8

require 'test_helper'

class PackerTest < Minitest::Test

  attr_reader :packer

  def setup
    @packer = AionS3::Packer.new
  end

  def test_random_password
    password = AionS3::Packer.random_password
    refute_nil password
  end

  def test_random_password_longer
    password = AionS3::Packer.random_password(48)
    refute_nil password
    assert_equal 64, password.size
  end

  def test_password_reader
    p1 = AionS3::Packer.new
    refute_nil(p1.password)
  end

  def test_password_different
    p1 = AionS3::Packer.new
    p2 = AionS3::Packer.new

    refute_equal(p1.password, p2.password)
  end

  def test_password_limit
    password = AionS3::Packer.random_password

    assert_raises(ArgumentError) do
      AionS3::Packer.new(password[0,31])
    end
  end

  def test_decryption_error
    p1 = AionS3::Packer.new
    p2 = AionS3::Packer.new

    encrypted_data = p1.encrypt('encrypted')

    refute_equal(p1.password, p2.password)
    assert_raises(OpenSSL::Cipher::CipherError) do
      p2.decrypt(encrypted_data)
    end
  end

  def test_encrypt_decrypt
    data = 'æøå'.force_encoding(Encoding::BINARY)
    data2 = packer.decrypt(packer.encrypt(data))

    assert_equal(data2.encoding, Encoding::BINARY)
    assert_equal(data, data2)
  end

  def test_multiple_packers
    p1 = AionS3::Packer.new
    p2 = AionS3::Packer.new(p1.password)

    data = 'æøå'.force_encoding(Encoding::BINARY)
    data2 = p2.decrypt(p1.encrypt(data))

    assert_equal(data2.encoding, Encoding::BINARY)
    assert_equal(data, data2)
  end

  # It is expected that decrypt will always
  def test_encrypt_decrypt_utf8
    data = 'æøå'
    data2 = packer.decrypt(packer.encrypt(data))

    assert_equal(data.bytes, data2.bytes)
    assert_equal(data2.encoding, Encoding::BINARY)
  end

  def test_encrypted_encoding
    encrypted = packer.encrypt('æøå')

    assert_equal(encrypted.encoding, Encoding::BINARY)
  end

  def test_deflated_encoding
    deflated = packer.deflate('æøå')

    assert_equal(deflated.encoding, Encoding::BINARY)
  end

  def test_deflate_inflate
    data = 'payload...'
    data2 = packer.inflate(packer.deflate(data))

    assert_equal(data, data2)
  end

  def test_deflate_inflate_utf8
    data = 'æøå'
    data2 = packer.inflate(packer.deflate(data))

    assert_equal(data.bytes, data2.bytes)
    assert_equal(data2.encoding, Encoding::BINARY)
  end

  def test_pack_unpack
    data = 'payload...'
    data2 = packer.unpack(packer.pack(data))

    assert_equal(data, data2)
  end

  def test_pack_unpack_utf8
    data = 'æøå'
    data2 = packer.unpack(packer.pack(data))

    assert_equal(data.bytes, data2.bytes)
    assert_equal(data2.encoding, Encoding::BINARY)
  end

  def test_file_pack_unpack
    data = File.read('test/random_data', mode: 'rb')
    data2 = packer.unpack(packer.pack(data))
    assert_equal(data, data2)
  end

  def test_file_pack_unpack_utf8
    data = File.read('test/random_data')
    data2 = packer.unpack(packer.pack(data))

    assert_equal(data.bytes, data2.bytes)
    assert_equal(data2.encoding, Encoding::BINARY)
  end

end
