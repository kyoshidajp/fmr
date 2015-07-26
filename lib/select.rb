require 'sqlite3'
require 'time'
require 'common'
require 'lib/base'

module FujiMountainRace

  # DBからデータを取得して様々な分析を行うクラス
  class Select < Base

    private

    # 時間内完走者のうち、チェックポイントの時間別完走率
    #
    # 開始時間（range_start）から間隔（range_sec）毎に
    # 算出
    #
    # @param [String] check_point チェックポイントカラム名
    # @param [String] range_start 開始時間
    # @param [String] range_end 終了時間
    # @param [String] range_sec 間隔（秒）
    def ratio_point(check_point, range_start, range_end, range_sec)
      range_end_time = Time.parse(range_end)
      current_time = Time.parse(range_start)
      format = '%H:%M:%S'
      selected_under = false
      while current_time <= range_end_time
        plus_current_time = current_time + range_sec
        current_time_str = current_time.strftime(format)
        plus_current_time_str = plus_current_time.strftime(format)

        where_numer = "check4 <= '#{@goal_limit}' "
        point_str = "#{Config.check_point(check_point)}通過が"
        if current_time <= Time.parse(range_start) && !selected_under
          where = "#{check_point} <= '#{current_time_str}'"
          point_str += "#{current_time_str}以内"
        else
          where = "'#{current_time_str}' < #{check_point} "\
        "and #{check_point} < '#{plus_current_time_str}'"
          point_str += "#{current_time_str}-#{plus_current_time_str}"
        end
        where_numer += "and #{where}"
        where_denom = where

        print "#{point_str}の完走率\n"
        sql_numer = "select (select count(*) from #{@table_name} where "\
      "#{where_numer})"
        count_numer = get_first_row(sql_numer)
        sql_denom = "select count(*) from #{@table_name} where #{where_denom}"
        count_denom = get_first_row(sql_denom)

        print "\t#{(count_numer / count_denom.to_f * 100).round(2)}%"\
      "(#{count_numer}/#{count_denom})\n"

        current_time = plus_current_time if selected_under
        selected_under = true
      end
    end

    # 完走率
    def finish_ratio
      print "時間内完走率\n"
      sql = "select (select count(*) from #{@table_name} "\
        "where check4 <= '#{@goal_limit}') * 100.0 /  "\
        "( select count(*) from #{@table_name} where check1 is not null)"
      exec_sql(sql)
    end

    # 時間内完走のうち、チェックポイントを最も遅く通過した選手の成績
    #
    # @param [String] check_point チェックポイントカラム名
    # @param [Fixnum] num 表示件数
    def last_records(check_point, num)
      print "時間内完走のうち、#{Config.check_point(check_point)}"\
        "を最も遅く通過した選手#{num}名の成績\n"
      sql = "select number, name, check1, check2, check3, check4 "\
        "from #{@table_name} where check4 <= '#{@goal_limit}' "\
        "order by #{check_point} desc limit #{num}"
      exec_sql(sql)
    end

    # チェックポイントを通過した完走者数
    #
    # @param [String] check_point チェックポイントカラム名
    # @param [String] after_time 以降の時間
    # @return [Fixnum] 完走者数
    def last_count(check_point, after_time)
      print "#{Config.check_point(check_point)}を#{after_time}"\
        "以降に通過した完走者数\n"
      sql = "select count(*) from #{@table_name} "\
        "where #{check_point} > '#{after_time}' and "\
        "check4 <= '#{@goal_limit}'"
      exec_sql(sql)
    end

    # SQLを実行して結果を出力
    #
    # @param [String] sql SQL
    def exec_sql(sql)
      print "\tSQL: #{sql}\n"
      @db.execute(sql) do |row|
        print "\t#{row.join(' ')}\n"
      end
    end

    # SQLを実行して結果の最初の1件を取得
    #
    # @param [String] sql SQL
    # @return [String] 実行結果の最初の1件
    def get_first_row(sql)
      print "\tSQL: #{sql}\n"
      @db.execute(sql) do |row|
        return row[0]
      end
    end

    # 様々な分析を行う
    def exec
      finish_ratio

      last_records('check1', 10)
      last_records('check2', 10)
      last_records('check3', 10)
      last_records('check4', 10)

      ratio_point('check2', '02:00:00', '02:20:00', 5*60)
      last_count('check2', '02:15:00')
    end

  end
end