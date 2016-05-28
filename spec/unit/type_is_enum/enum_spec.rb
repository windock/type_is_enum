# coding: utf-8
require 'spec_helper'

class Suit < TypeIsEnum::Enum
  add :CLUBS
  add :DIAMONDS
  add :HEARTS
  add :SPADES
end

class Tarot < TypeIsEnum::ValueEnum
  add :CUPS, 'Cups'
  add :COINS, 'Coins'
  add :WANDS, 'Wands'
  add :SWORDS, 'Swords'
end

class RGBColor < TypeIsEnum::ValueEnum
  add :RED, :red
  add :GREEN, :green
  add :BLUE, :blue
end

class Scale < TypeIsEnum::ValueEnum
  add :DECA, 10
  add :HECTO, 100
  add :KILO, 1_000
  add :MEGA, 1_000_000
end

class Car < TypeIsEnum::Enum
  def initialize(price, coolness)
    @price = price
    @coolness = coolness
  end

  attr_reader :price, :coolness

  add :Audi, 25_000, 4
  add :Mercedes, 30_000, 6
  add :Toyota, 10_000, 2
end

module TypeIsEnum
  describe Enum do

    it 'allows custom constructors with multiple arguments' do
      expect(Car.to_a).to contain_exactly(
        have_attributes(price: 25_000, coolness: 4),
        have_attributes(price: 30_000, coolness: 6),
        have_attributes(price: 10_000, coolness: 2)
      )
    end

    describe '::add' do
      it ' adds a constant enum value' do
        enum = Suit::CLUBS
        expect(enum).to be_a(Suit)
      end

      it 'insists symbols be symbols' do
        expect do
          class ::StringKeys < ValueEnum
            add 'spades', 'spades'
          end
        end.to raise_error(TypeError)
        expect(::StringKeys.to_a).to be_empty
      end

      it 'insists symbols be uppercase' do
        expect do
          class ::LowerCaseKeys < ValueEnum
            add :spades, 'spades'
          end
        end.to raise_error(NameError)
        expect(::LowerCaseKeys.to_a).to be_empty
      end

      it 'disallows nil keys' do
        expect do
          class ::NilKeys < ValueEnum
            add nil, 'nil'
          end
        end.to raise_error(TypeError)
        expect(::NilKeys.to_a).to be_empty
      end

      it 'allows, but ignores redeclaration of identical instances' do
        class ::IdenticalInstances < ValueEnum
          add :SPADES, 'spades'
        end
        expect(::IdenticalInstances).to receive(:warn).with(a_string_matching(/ignoring redeclaration of IdenticalInstances::SPADES/))
        class ::IdenticalInstances < ValueEnum
          add :SPADES, 'spades'
        end
        expect(::IdenticalInstances.to_a).to eq([::IdenticalInstances::SPADES])
      end

      it 'is private' do
        expect { Tarot.add(:PENTACLES) }.to raise_error(NoMethodError)
      end
    end

    describe '::to_a' do
      it 'returns the values as an array' do
        expect(Suit.to_a).to eq([Suit::CLUBS, Suit::DIAMONDS, Suit::HEARTS, Suit::SPADES])
      end
      it 'returns a copy' do
        array = Suit.to_a
        array.clear
        expect(array.empty?).to eq(true)
        expect(Suit.to_a).to eq([Suit::CLUBS, Suit::DIAMONDS, Suit::HEARTS, Suit::SPADES])
      end
    end

    describe '::size' do
      it 'returns the number of enum instnaces' do
        expect(Suit.size).to eq(4)
      end
    end

    describe '::each' do
      it 'iterates the enum values' do
        expected = [Suit::CLUBS, Suit::DIAMONDS, Suit::HEARTS, Suit::SPADES]
        index = 0
        Suit.each do |s|
          expect(s).to be(expected[index])
          index += 1
        end
      end
    end

    describe '::each_with_index' do
      it 'iterates the enum values with indices' do
        expected = [Suit::CLUBS, Suit::DIAMONDS, Suit::HEARTS, Suit::SPADES]
        Suit.each_with_index do |s, index|
          expect(s).to be(expected[index])
        end
      end
    end

    describe '::map' do
      it 'maps enum values' do
        all_keys = Suit.map(&:key)
        expect(all_keys).to eq([:CLUBS, :DIAMONDS, :HEARTS, :SPADES])
      end
    end

    describe '#<=>' do
      it 'orders enum instances' do
        Suit.each_with_index do |s1, i1|
          Suit.each_with_index do |s2, i2|
            expect(s1 <=> s2).to eq(i1 <=> i2)
          end
        end
      end
    end

    describe '#==' do
      it 'returns true for identical instances, false otherwise' do
        Suit.each do |s1|
          Suit.each do |s2|
            identical = s1.equal?(s2)
            expect(s1 == s2).to eq(identical)
          end
        end
      end

      it 'reports instances as unequal to nil and other objects' do
        a_nil_value = nil
        Suit.each do |s|
          expect(s.nil?).to eq(false)
          expect(s == a_nil_value).to eq(false)
          Tarot.each do |t|
            expect(s == t).to eq(false)
            expect(t == s).to eq(false)
          end
        end
      end

      it 'survives marshalling' do
        Suit.each do |s1|
          dump = Marshal.dump(s1)
          s2 = Marshal.load(dump)
          expect(s1 == s2).to eq(true)
          expect(s2 == s1).to eq(true)
        end
      end
    end

    describe '#!=' do
      it 'returns false for identical instances, true otherwise' do
        Suit.each do |s1|
          Suit.each do |s2|
            different = !s1.equal?(s2)
            expect(s1 != s2).to eq(different)
          end
        end
      end

      it 'reports instances as unequal to nil and other objects' do
        a_nil_value = nil
        Suit.each do |s|
          expect(s != a_nil_value).to eq(true)
          Tarot.each do |t|
            expect(s != t).to eq(true)
            expect(t != s).to eq(true)
          end
        end
      end
    end

    describe '#hash' do
      it 'gives consistent values' do
        Suit.each do |s1|
          Suit.each do |s2|
            expect(s1.hash == s2.hash).to eq(s1 == s2)
          end
        end
      end

      it 'returns different values for different types' do
        class Suit2 < ValueEnum
          add :CLUBS, 'Clubs'
          add :DIAMONDS, 'Diamonds'
          add :HEARTS, 'Hearts'
          add :SPADES, 'Spades'
        end

        Suit.each do |s1|
          s2 = Suit2.find_by_key(s1.key)
          expect(s1.hash == s2.hash).to eq(false)
        end
      end

      it 'survives marshalling' do
        Suit.each do |s1|
          dump = Marshal.dump(s1)
          s2 = Marshal.load(dump)
          expect(s2.hash).to eq(s1.hash)
        end
      end

      it 'always returns a Fixnum' do
        Suit.each do |s1|
          expect(s1.hash).to be_a(Fixnum)
        end
      end
    end

    describe '#eql?' do
      it 'is consistent with #hash' do
        Suit.each do |s1|
          Suit.each do |s2|
            expect(s1.eql?(s2)).to eq(s1.hash == s2.hash)
          end
        end
      end
    end

    describe '#key' do
      it 'returns the symbol key of the enum instance' do
        expected = [:CLUBS, :DIAMONDS, :HEARTS, :SPADES]
        Suit.each_with_index do |s, index|
          expect(s.key).to eq(expected[index])
        end
      end
    end

    describe '#ord' do
      it 'returns the ord value of the enum instance' do
        Suit.each_with_index do |s, index|
          expect(s.ord).to eq(index)
        end
      end
    end

    describe '#to_s' do
      it 'provides an informative string' do
        aggregate_failures 'informative string' do
          [Suit, Tarot, RGBColor, Scale].each do |ec|
            ec.each do |ev|
              result = ev.to_s
              [ec.to_s, ev.key, ev.ord].each do |info|
                expect(result).to include("#{info}")
              end
            end
          end
        end
      end
    end

    describe '::find_by_key' do
      it 'maps symbol keys to enum instances' do
        keys = [:CLUBS, :DIAMONDS, :HEARTS, :SPADES]
        expected = Suit.to_a
        keys.each_with_index do |k, index|
          expect(Suit.find_by_key(k)).to be(expected[index])
        end
      end

      it 'returns nil for invalid keys' do
        expect(Suit.find_by_key(:WANDS)).to be_nil
      end
    end

    describe '::find_by_ord' do
      it 'maps ordinal indices to enum instances' do
        Suit.each do |s|
          expect(Suit.find_by_ord(s.ord)).to be(s)
        end
      end

      it 'returns nil for negative indices' do
        expect(Suit.find_by_ord(-1)).to be_nil
      end

      it 'returns nil for out-of-range indices' do
        expect(Suit.find_by_ord(Suit.size)).to be_nil
      end

      it 'returns nil for invalid indices' do
        expect(Suit.find_by_ord(100)).to be_nil
      end
    end

    it 'supports case statements' do
      def pip(suit)
        case suit
        when Suit::CLUBS
          '♣'
        when Suit::DIAMONDS
          '♦'
        when Suit::HEARTS
          '♥'
        when Suit::SPADES
          '♠'
        else
          fail "unknown suit: #{self}"
        end
      end

      expect(Suit.map { |s| pip(s) }).to eq(%w(♣ ♦ ♥ ♠))
    end

    it 'supports "inner class" methods' do
      class Operation < ValueEnum
        add(:PLUS, '+') do
          def eval(x, y)
            x + y
          end
        end
        add(:MINUS, '-') do
          def eval(x, y)
            x - y
          end
        end
      end

      expect(Operation.map { |op| op.eval(39, 23) }).to eq([39 + 23, 39 - 23])
    end
  end
end
