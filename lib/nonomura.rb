# encoding: utf-8

# require mecab on shell

require 'romaji'

module Nonomura
  def self.translate(text, level=10)
    parsed = parse(text)

    dic = dictionary(level.to_i)
    parsed.inject(""){|memo, arr|
      if dic[arr[0]]
        memo << arr[1] + dic[arr[0]].sample
      else
        memo << arr[1] + dic[nil].sample
      end
    }
  end

  def self.dictionary(level)
    @_dictionary ||= []
    @_dictionary[level] ||=
      {
        nil => dictionary_nil.concat(Array.new(level, '')),
        'a' => dictionary_A.concat(Array.new(level, '')),
        'i' => nil,
        'u' => dictionary_U.concat(Array.new(level, '')),
        'e' => dictionary_E.concat(Array.new(level, '')),
        'o' => nil,
        'n' => dictionary_N.concat(Array.new(level, ''))
      }
  end

  # 母音が見つからなかった場合
  def self.dictionary_nil
    ['', 'ﾝｧｯ↑ﾊｯﾊｯ', '…ｸﾞｽﾞｯ…', 'ﾝｩｯﾊｰ↑', 'ｸﾞｽﾞｯ', 'ｱ゛ｧｱﾝ！！！', 'ﾝﾄﾞｩｯﾊｯﾊｯﾊｯﾊｯﾊｱｱｱｱｧｧ↑']
  end

  # 母音判別
  def self.dictionary_A
    ['','ﾊｯﾊｰｗｗｗｗｗｗｳ゛ﾝ！！', 'ｱｧﾝ！！！！！！', 'ｱｩｯｱｩｵｩｳ', 'ｱ゛ｱｱｱｱｱｱｱｱｱｱｱｱｱーーーｩｱﾝ！']
  end

  def self.dictionary_I
    nil
  end

  def self.dictionary_U
    ['','ｩｧｩｧ……ｩ゛ー！', 'ｩｵｩｳｱ゛ｱｱｱｱｱｱｱｱｱｱｱｱｱーーーｩｱﾝ', 'ｩｯﾊｰ↑ｸﾞｽﾞｯ']
  end

  def self.dictionary_E
    ['','ﾃﾞｰ！', 'ｯﾍｯﾍｴｴｪｴｪｴｴｲ↑↑↑↑']
  end

  def self.dictionary_O
    nil
  end

  def self.dictionary_N
    ['','ﾝﾌﾝﾌﾝｯﾊ ｱｱｱｱｱｱｱｱｱ↑↑↑', 'ﾝﾄﾞｩｯﾊｯﾊｯﾊｯﾊｯﾊｱｱｱｱｧｧ↑']
  end

  def self.parse(text)
    (`echo "#{text}" | mecab`).split("\n").map{|line|
      begin
        a = line.split("\t")[0].gsub(/EOS/, '')
        b = Romaji.kana2romaji( line.split(",").last )[-1,1]

        t = []
        t[0] = b
        t[1] = a
      rescue NoMethodError
        t = nil
      end

      t
    }
  end
end