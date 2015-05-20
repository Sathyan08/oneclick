class User

  class AddSubAccount
    attr_reader :main

    def self.call(main, sub)
      user = new(main, sub)
      user.main
    end

    private

    def initialize(main, sub_account)
      @main = main
      @sub_account = sub_account
      add_sub_to_main
    end

    def add_sub_to_main
      @main.instance_variable_set(:@sub, @sub_account)

      def @main.sub
        @sub
      end
    end

  end
end
