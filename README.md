AionS3
===

This module provides utilities for compressing and encrypting data, as well as uploading
compliance locked objects to AWS s3.

### AWS credentials

It is possible to read AWS credentials and region information from a file.
For more information read documentation for 
[Aws::S3::Client.initialize](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method) 

#### Example of file <code>~/.aws/credentials</code>
```
[default]
aws_access_key_id=INSERT_ACCESS_KEY_ID_HERE
aws_secret_access_key=INSERT_ACCESS_KEY_HERE
region=eu-north-1
```

#### Pack and upload file

```ruby
require 'aion-s3'

source_path = 'path/to/source/file'
password = "deD4G0pQm41rlPSOgQx59X/gDriMFk0F"
packer = AionS3::Packer.new(password)

packed_body = packer.pack(File.read(source_path, mode: 'rb'))

bucket = 'target-bucket-name'
uploader = AionS3::Uploader.new(bucket, lock_days: 30)

key = 'bucket/path/to/target.packed'
uploader.put(key, packed_body)
```

#### Download and unpack file

```ruby
require 'aion-s3'
    
bucket = 'target-bucket-name'
uploader = AionS3::Uploader.new(bucket)

key = 'bucket/path/to/target.packed'
packed_body = StringIO.open { |io| uploader.get(key, io) }.string

password = "deD4G0pQm41rlPSOgQx59X/gDriMFk0F"
packer = AionS3::Packer.new(password)

body = packer.unpack(packed_body)

target_path = 'path/to/target/file'
File.open(target_path, 'wb') do |file|
  file.write(packer.unpack(packed_body))
end
```
