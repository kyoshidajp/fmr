require 'common'

module FujiMountainRace

  # ベースクラス
  class Base

    # initialize
    # 定数等の初期設定を行う
    #
    # @param [String] id レースID
    def initialize(id)
      proj_dir = File.expand_path('..', File.dirname(__FILE__))
      @db_file = File.join(proj_dir, Config::DB_NAME)
      @table_name = Config.table_name(id)
      @race_id = id
      @goal_limit = Config::GOAL_LIMIT

      require "#{@race_id}/config"
      @block = Config::START_BLOCK
    end

    public

    # メイン処理を行う
    def main
      begin
        @db = SQLite3::Database.new(@db_file)
        exec
      rescue SQLite3::Exception => e
        p e.message
      ensure
        @db.close if @db
      end
    end
  end
end
