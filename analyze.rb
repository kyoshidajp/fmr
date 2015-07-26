$:.unshift File.dirname(__FILE__)
require 'lib/insert'
require 'lib/select'

# TODO:
race_id = "#{Date.today.strftime('%Y')}fujitozan"

insert = FujiMountainRace::Insert.new(race_id)
insert.main

select = FujiMountainRace::Select.new(race_id)
select.main