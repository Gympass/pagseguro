module PagSeguro
  class Order
    # Map all billing attributes that will be added as form inputs.
    BILLING_MAPPING = {
      :name                  => "cliente_nome",
      :address_zipcode       => "cliente_cep",
      :address_street        => "cliente_end",
      :address_number        => "cliente_num",
      :address_complement    => "cliente_compl",
      :address_neighbourhood => "cliente_bairro",
      :address_city          => "cliente_cidade",
      :address_state         => "cliente_uf",
      :address_country       => "cliente_pais",
      :phone_area_code       => "cliente_ddd",
      :phone_number          => "cliente_tel",
      :email                 => "cliente_email"
    }

    # Optional: extra amount on the purchase (negative for discount
    attr_accessor :extra_amount
    
    # The list of products added to the order
    attr_accessor :products

    # The billing info that will be sent to PagSeguro.
    attr_accessor :billing

    # Define the shipping type.
    # Can be EN (PAC) or SD (Sedex)
    attr_accessor :shipping_type

    def initialize(order_id = nil)
      reset!
      self.id = order_id
      self.billing = {}
    end

    # Set the order identifier. Should be a unique
    # value to identify this order on your own application
    def id=(identifier)
      @id = identifier
    end

    # Get the order identifier
    def id
      @id
    end

    # Remove all products from this order
    def reset!
      @products = []
    end

    # Add a new product to the PagSeguro order
    # The allowed values are:
    # - weight (Optional. If float, will be multiplied by 1000g)
    # - shipping (Optional. If float, will be multiplied by 100 cents)
    # - quantity (Optional. Defaults to 1)
    # - price (Required. If float, will be multiplied by 100 cents)
    # - description (Required. Identifies the product)
    # - id (Required. Should match the product on your database)
    # - fees (Optional. If float, will be multiplied by 100 cents)
    def <<(options)
      options = {
        :weight => nil,
        :shipping => nil,
        :fees => nil,
        :quantity => 1
      }.merge(options)

      # convert shipping to cents
      options[:shipping] = convert_unit(options[:shipping], 100)

      # convert fees to cents
      options[:fees] = convert_unit(options[:fees], 100)

      # convert price to cents
      options[:price] = convert_unit(options[:price], 100)

      # convert weight to grammes
      options[:weight] = convert_unit(options[:weight], 1000)

      products.push(options)
    end

    def add(options)
      self << options
    end

    private
    def convert_unit(number, unit)
      number = (BigDecimal("#{number}") * unit).to_i unless number.nil? || number.kind_of?(Integer)
      "%03d" % number.to_i
    end
  end
end
