# coding: utf-8

module MyStrom
  class APIError < StandardError
    def initialize(msg)
      super(msg)
    end
  end
end
