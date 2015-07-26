module Config

  # チェックポイントと名称のマッピングテーブル
  CHECK_POINT_TABLE = {
      'check1' => '馬返し',
      'check2' => '五合目',
      'check3' => '八合目',
      'check4' => 'ゴール',
  }

  # ゴール制限時間
  GOAL_LIMIT = '04:30:00'

  # チェックポイントの名称を取得
  #
  # @param [String] name チェックポイントのフィールド名
  # @return [String] チェックポイントの名称
  def self.check_point(name)
    CHECK_POINT_TABLE[name]
  end

  DB_NAME = 'database.db'

  # テーブル名
  #
  # sqlite3の制約によりプレフィックスを付ける
  def self.table_name(name)
    "table_#{name}"
  end

end