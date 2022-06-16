class IposMarketingToolsController < ApplicationController
  def index
    begin
      resp = Faraday.get("http://goipos.net/api/v1/ipos_marketplaces") do |req|
        req.headers['accept'] = 'application/json'
        req.headers['TOKEN'] = 'daa6ca0d923eb52a48259d7eb4eac8de'
      end
      response_body = JSON.parse(resp.body)
      @marketplaces = response_body['data']
      @error = true unless response_body['status'] == 200
    rescue
      @error = "Parent Host didn't respond properly."
    end
  end
end