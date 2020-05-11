class String
  def url_encode
    CGI::escape(self)
  end
end