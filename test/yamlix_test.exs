defmodule YamlixTest do
  use ExUnit.Case
  
  def pasre_with_yamerl(str) do
    str
    |> String.to_char_list
    |> :yamerl_constr.string([{:node_mods, [:yamerl_node_erlang_atom]}])
  end

  test "it dumps integer scalars" do
    assert Yamlix.dump(5) == "--- 5\n...\n"
  end

  test "it dumps string scalars" do
    assert Yamlix.dump("s") == "--- s\n...\n"
  end

  test "it dumps maps of strings" do
    map = %{"key1" => "value1", "key2" => "value2"}
    assert Yamlix.dump(map) == """
    --- 
    key1: value1
    key2: value2
    ...
    """
  end

  test "it dumps emtpy maps" do
    assert Yamlix.dump(%{}) == """
    --- 
    ...
    """
  end

  test "it dumps emtpy lists" do
    assert Yamlix.dump([]) == """
    --- 
    ...
    """
  end

  test "it dumps lists of strings" do
    list = ["one", "two"]
    assert Yamlix.dump(list) == """
    --- 
    - one
    - two
    ...
    """
  end
  
  test "it dumps empty maps in a list" do
    list = [%{ "a" => "b"}, %{}]
    assert Yamlix.dump(list) == """
    --- 
    - a: b
    - {}
    ...
    """
  end

  test "it dumps floats" do
    assert Yamlix.dump(5.0) == "--- 5.0\n...\n"
  end

  test "it dumps bools (true)" do
    assert Yamlix.dump(true) == "--- true\n...\n"
  end

  test "it dumps bools (false)" do
    assert Yamlix.dump(false) == "--- false\n...\n"
  end

  test "it dumps atoms with yamerl tag" do
    assert Yamlix.dump(:a) == "--- !<tag:yamerl,2012:atom> a\n...\n"
  end

  test "it dumps atoms that can be parsed by yamerl" do
    assert [:a] == Yamlix.dump(:a) |> pasre_with_yamerl
  end

  test "it indents" do
    complex = %{
      "key1" => [ "elem1", "elem2", "elem3" ],
      "key2" => %{ 1 => "a", 2 => "b" },
      "key3" => 4,
      "key4" => [
        %{ "aa" => "w", "bb" => [ "p", "q" ] },
        %{ "cc" => "y", "dd" => "z" }
      ],
      "key5" => 5
    }
    # Expected data generated by Ruby's YAML support
    assert Yamlix.dump(complex) == """
    --- 
    key1:
    - elem1
    - elem2
    - elem3
    key2:
      1: a
      2: b
    key3: 4
    key4:
    - aa: w
      bb:
      - p
      - q
    - cc: y
      dd: z
    key5: 5
    ...
    """
  end
  
  @tag :disable
  test "it handles repeated structures" do
    repeated = %{ "a" => "b", "c" => "d" }
    other = %{ "e" => "f" }
    graph = [repeated, other, repeated]
    
    assert Yamlix.dump(graph) == """
    ---
    - &1
      a: b
      c: d
    - e: f
    - *1
    ...
    """
  end
end
