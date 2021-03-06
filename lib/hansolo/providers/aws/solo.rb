module Hansolo::Providers::AWS
  module Solo
    def sync_data_bags
      threads = hosts.map do |host|
        Thread.new do
          ssh = connect(host)

          command = data_bag_items.inject([]) do |cmd, object|
            key = object.key.sub("#{Hansolo.app}/", '')
            path = Pathname.new('/tmp/data_bags').join(key)

            cmd << "mkdir -p #{path.dirname}"
            cmd << "echo '#{object.read}' > #{path}"
          end

          ssh.exec! command.join('; ')
          ssh.close
        end
      end

      threads.map(&:join)
    end

    def data_bag_items
      bucket.objects.with_prefix(Hansolo.app)
    end
  end
end
