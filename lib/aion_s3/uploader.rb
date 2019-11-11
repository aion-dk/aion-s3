require 'aws-sdk-s3'

module AionS3

  # An <code>Uploader</code> is a utility for uploading data to s3.
  # The Uploader supports compliance locking, where files are locked for update/deletion for a configured amount of time.
  #
  # The utility is a wrapper around <code>Aws::S3::Client</code>.
  class Uploader

    # @return [Aws::S3::Client]
    attr_reader :client

    # @param [String] bucket
    # @param [Integer] lock_days
    # @param [Hash] s3_options
    def initialize(bucket, lock_days: 0, s3_options: {})
      @client = Aws::S3::Client.new(s3_options)
      @bucket = bucket
      @lock_seconds = lock_days.to_i * 24 * 60 * 60
    end

    # Gets metadata from an object in s3.
    #
    # If a target is provided, the object data will be downloaded as well.
    # +target+ must be a string with file path or an <code>IO</code> object.
    #
    # @param [String] key
    # @param [String, IO] target
    # @return [Aws::S3::Types::GetObjectOutput]
    def get(key, target = nil)
      @client.get_object(
          bucket: @bucket,
          key: key,
          response_target: target
      )
    end

    # Puts an object to s3.
    #
    # If <code>Uploader</code> was configured with lock_days > 0 a compliance lock will be put on the object.
    #
    # @param [String] key an urlsafe string
    # @param [String, IO] body
    # @return [Aws::S3::Types::PutObjectOutput]
    def put(key, body)
      options = {
          bucket: @bucket,
          key: key,
          body: body,
      }

      if @lock_seconds > 0
        options = {
            object_lock_mode: 'COMPLIANCE',
            object_lock_retain_until_date: Time.now + @lock_seconds
        }.merge(options)
      end

      @client.put_object(options)
    end

  end
end
