require 'date'
require 'json'

module FlightStats
  class Resource
    # Performance optimizations
    @@string_to_model_cache_lock = Mutex.new
    @@string_to_model_cache = {}
    class UnknownModel ; end
    @@underscore_cache_lock = Mutex.new
    @@underscore_cache = {}

    class << self
      # Instantiates a record from an HTTP response.
      #
      # @return [Resource]
      # @param response [Net::HTTPResponse]
      # @param response_key [String]
      def from_response response, response_key=nil
        record = from_json response.body, response_key
        record.instance_eval { @etag, @response = response['ETag'], response }
        record
      end

      # Instantiates a record from a JSON blob.
      #
      # @return [Resource]
      # @param json [String]
      # @param response_key [String]
      # @see from_response
      def from_json json, response_key
        model = nil
        raw = JSON.parse(json)
        response_key ? from_parsed_json(raw[response_key].nil? ? raw : raw[response_key], response_key) : raw
      end

      # Given a string (key in the response json), find the right model.
      #
      # @return [Resource] class corresponding to the string, nil if no model is associated with it
      # @param model_string [String]
      # @see from_response
      def string_to_model(model_string)
        return nil if model_string.nil?
        begin
          class_name = Helper.classify(model_string)
          FlightStats.const_get(class_name)
        rescue NameError => e
          # FlightStats.logger.warn e
          nil
        end
      end

      def string_to_model_with_caching(model_string)
        @@string_to_model_cache_lock.synchronize do
          model = @@string_to_model_cache[model_string]
          return nil if model == UnknownModel
          return model unless model.nil?

          # See if it's a series of objects (e.g. schedules)
          model = string_to_model(Helper.singularize(model_string))
          model = string_to_model(model_string) if model.nil?

          @@string_to_model_cache[model_string] = model.nil? ? UnknownModel : model
          return model
        end
      end

      JSON_PRIMITIVES = %w[FalseClass TrueClass Integer String].freeze
      def from_parsed_json(json, model_string)
        # Optimization - native type, nothing to build so bail early
        return json if JSON_PRIMITIVES.include?(json.class.name)
          
        if json.is_a?(Array)
          value = []
          json.each do |one_value|
            value << from_parsed_json(one_value, model_string)
          end
          value
        else
          model = string_to_model_with_caching(model_string)

          if !model.nil? and !json.is_a?(Hash)
            json
          else
            model.nil? ? json : model.send("new", json)
          end
        end
      end
    end

    # @return [Hash] The raw hash of record attributes.
    attr_reader :attributes

    # @return [Net::HTTPResponse, nil] The most recent response object for the record.
    attr_reader :response

    # @return [String, nil] An ETag for the current record.
    attr_reader :etag

    # @return [String, nil] A writer to override the URI the record saves to.
    attr_writer :uri

    # @return [Resource] A new resource instance.
    # @param attributes [Hash] A hash of attributes.
    def initialize attributes = {}
      if instance_of? Resource
        raise Error, "#{self.class} is an abstract class and cannot be instantiated"
      end

      @attributes, @uri, @href = {}, false, false
      self.attributes = attributes
      yield self if block_given?
    end

    def underscore_with_caching(input_string)
      @@underscore_cache_lock.synchronize do
        underscored = @@underscore_cache[input_string]
        return underscored unless underscored.nil?

        underscored = Helper.underscore(input_string)

        @@underscore_cache[input_string] = underscored
        return underscored
      end
    end

    # Apply a given hash of attributes to an object.
    #
    # @return [Hash]
    # @param attributes [Hash] A hash of attributes.
    def attributes= attributes = {}
      return if attributes.nil?
      attributes.each_pair { |k, v|
        # Parse the nested attributed to instantiate the right model, is applicable
        value = FlightStats::Resource.from_parsed_json(v, k)
        send("#{underscore_with_caching(k)}=", value) rescue nil
      }
    end

    def to_param
      self[self.class.param_name]
    end
  end
end
