# frozen_string_literal: true

module Callgraph
  module EventDefaults
    def receiver_class
      case method_type
      when :class, :module
        receiver
      else
        receiver.class
      end
    end

    def defined_class_name
      @defined_class_name ||= case method_type
      when :class, :module
        receiver_class.to_s
      when :singleton
        defined_class.to_s.match(/#<Class:(.*)>/).captures[0]
      when :instance
        defined_class.to_s
      end
    end

    def defined_path
      source_location[0]
    end

    def defined_line_number
      source_location[1]
    end

    def method_string
      @method_string ||= case method_type
      when :class, :module
        "#{receiver_class}.#{method_name}"
      when :singleton
        "#{receiver_class}##{method_name} (singleton)"
      when :instance
        "#{defined_class}##{method_name}"
      end
    end

    def method_type
      @method_type ||= begin
        if receiver.class == Class
          :class
        elsif receiver.class == Module
          :module
        elsif defined_class.singleton_class?
          :singleton
        else
          :instance
        end
      end
    end

    def source_location
      @source_location ||= defined_class.instance_method(method_name).source_location
    end
  end
end
