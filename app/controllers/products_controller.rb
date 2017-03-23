class ProductsController < ApplicationController
	def index
		@products = Product.all
	end

	def show
		@product = Product.find(params[:id])
	end

	def crawl
		request = Vacuum.new

		request.configure(
          aws_access_key_id: ENV["aws_access_key_id"],
          aws_secret_access_key: ENV["aws_secret_access_key"],
          associate_tag: ENV["associate_tag"]
        )

		params = {
			'SearchIndex' => 'FashionWomen',
			'Brand' => 'Lacoste',
			'Availability' => 'Available',
			'Keywords' => 'shirts',		
			'ResponseGroup' => 'ItemAttributes, Images'
		}

		raw_products = request.item_search(query: params)
		hashed_products = raw_products.to_h
		#binding.pry
		@products = []

		flash[:now] = hashed_products['ItemSearchResponse']['Items']['Item'].length
	    hashed_products['ItemSearchResponse']['Items']['Item'].each do |item|
        #  binding.pry
        product = Product.new
        product.title = item['ItemAttributes']['Title']
        product.image_url = item['MediumImage']['URL']
        product.description = item['ItemAttributes']['Feature'].is_a?(Array) ?  item['ItemAttributes']['Feature'].join("\n") : item['ItemAttributes']['Feature']
       
        @products << product
      end
  end
end
