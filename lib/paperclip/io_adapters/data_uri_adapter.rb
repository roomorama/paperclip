module Paperclip
  class DataUriAdapter < StringioAdapter

    REGEXP = /\Adata:([-\w]+\/[-\w\+]+);base64,(.*)/m

    def initialize(target_uri)
      @target_uri = target_uri
      cache_current_values
      @tempfile = copy_to_tempfile
    end

    private

    def cache_current_values
      data_uri_parts ||= @target_uri.match(REGEXP) || []
      @content_type = ContentTypeDetector.new(@tempfile.path)
      self.original_filename = "data.#{extension_for(@content_type)}"
      @target = StringIO.new(Base64.decode64(data_uri_parts[2] || ''))
      @size = @target.size
    end

    def extension_for(content_type)
      type = MIME::Types[content_type].first
      type && type.extensions.first
    end

  end
end

Paperclip.io_adapters.register Paperclip::DataUriAdapter do |target|
  String === target && target =~ Paperclip::DataUriAdapter::REGEXP
end
