require 'runners_update'
require 'sqlite3'
require 'common'
require 'lib/base'

module FujiMountainRace

  # DBにデータを挿入するクラス
  class Insert < Base

    private

    def exec
      result = RunnersUpdate.get(@race_id, *@block)

      sql = <<"SQL"
CREATE TABLE #{@table_name} (
  number integer,
  name   varchar(200),
  check1 varchar(200),
  check2 varchar(200),
  check3 varchar(200),
  check4 varchar(200)
);
SQL

      @db.execute(sql)

      result.each do |runner|
        @db.transaction do
          points = []
          runner.splits.each do |s|
            points << s.split
          end

          # nil padding
          points.fill(nil, points.size..3)

          sql = "insert into #{@table_name} values (?, ?, ?, ?, ?, ?)"
          @db.execute(sql, runner.number, runner.name,
                      points[0], points[1], points[2], points[3])
        end
      end
    end

  end
end
