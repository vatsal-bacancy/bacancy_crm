class SendHttpRequest

	def initialize(api,request_type,data)
		@api = api
		@request_type = request_type
		@data = data
	end

	def http_process
		url_initialization
		set_header
		http_initialization
		request_initialization
		send_request
	end

	def url_initialization
		# url = "https://pro1.cellnuvo.com/api/v1/bQ62s1pkJGAbqR/" + @api
		# url = "https://dev3.cellnuvo.com/api/v1/bQ62s1pkJGAbqR/" + @api
		url = Env.request_url + @api
		@uri = URI.parse(url)
	end

	def set_header
		@header = {'X-HTTP-Method-Override' => 'PUT'}
	end

	def http_initialization
		@http = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = false
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	end

	def request_initialization
		if @request_type == "POST"
      @request = Net::HTTP::Post.new(@uri.request_uri, @header)
      params = {:data => "#{@data}",:from => "webview"}
      @request.set_form_data(params)
    else
      @request = Net::HTTP::Get.new(@uri.request_uri+ "/#{@data}", @header)
    end
	end

	def send_request
		@res = @http.request(@request).body.gsub('NULL', 'null')
    puts"====response====#{@res}======="
    @res = JSON.parse(@res) rescue @res
	end

end
