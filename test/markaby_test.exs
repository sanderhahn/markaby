defmodule MarkabyTest do
  use ExUnit.Case
  doctest Markaby

  import Kernel, except: [div: 2]

  import Markaby

  def str(iodata) do
    iodata
    |> escape_html
    |> IO.iodata_to_binary
  end

  test "tag" do
    assert str(tag("a", href: "/path?one&two") do "link" end) == ~s(<a href="/path?one&amp;two">link</a>)
  end

  test "escape_html raw" do
    assert str(raw("<br>")) == ~s(<br>)
  end

  test "escape_html nested raw" do
    assert str(p(do: raw("<br>"))) == ~s(<p><br></p>)
  end

  test "tag with block" do
    assert str(tag("p", do: ["Hello & World"])) == "<p>Hello &amp; World</p>"
  end

  test "tag with raw" do
    assert str(tag("p", do: [raw("Hello &amp; World")])) == "<p>Hello &amp; World</p>"
  end

  test "br" do
    assert str(br()) == "<br>"
  end

  test "nil values" do
    assert str([[], nil, ""]) == ""
  end

  test "br invalid" do
    assert_raise ArgumentError, fn ->
      str(br(do: "paragraph")) == "<br>"
    end
  end

  test "p" do
    assert str(p(do: "paragraph")) == "<p>paragraph</p>"
  end

  test "ul with li tags" do
    li = ~w(one two tree) |> Enum.map(&li(do: &1))
    assert str(ul(do: li)) == "<ul><li>one</li><li>two</li><li>tree</li></ul>"
  end

  test "content block" do
    list =
      content do
        "one"
        "two"
        "tree"
      end
    assert list == ["one", "two", "tree"]
  end

  test "tag with content block" do
    html =
      div class: "content" do
        strong do: "strong"
        em do: "em"
      end
    assert str(html) == ~s(<div class="content"><strong>strong</strong><em>em</em></div>)
  end
end
