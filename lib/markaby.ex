defmodule Markaby do

  @tags ~w(
    a
    abbr
    address
    article
    aside
    audio
    b
    bdi
    bdo
    blockquote
    body
    button
    canvas
    caption
    cite
    code
    datalist
    dd
    del
    details
    dfn
    div
    dl
    dt
    em
    fieldset
    figcaption
    figure
    footer
    form
    h1
    h2
    h3
    h4
    h5
    h6
    head
    header
    hgroup
    html
    i
    iframe
    ins
    kbd
    label
    legend
    li
    map
    mark
    menu
    meter
    nav
    noscript
    object
    ol
    optgroup
    option
    output
    p
    pre
    progress
    q
    rp
    rt
    ruby
    s
    samp
    script
    section
    select
    small
    span
    strong
    style
    sub
    summary
    sup
    table
    tbody
    td
    textarea
    tfoot
    th
    thead
    time
    title
    tr
    u
    ul
    var
    video
  )a

  @empty_tags ~w(
    area
    base
    br
    col
    colgroup
    command
    embed
    hr
    img
    input
    keygen
    link
    meta
    param
    source
    track
    wbr
  )a

  @sorted_tags Enum.sort(@tags ++ @empty_tags)

  @link fn tag ->
    "[#{tag}](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/#{tag})"
  end

  @moduledoc """
  Markaby is clone of [Markaby](https://en.wikipedia.org/wiki/Markaby)
  for [Elixir](http://elixir-lang.org/) and is compatible with
  [Phoenix](http://www.phoenixframework.org/) views.

  ## Nesting

  Tag macros use do blocks to nest content and the result of every expression becomes
  part of the the html output. No output is generated on `nil` values.
  Unsafe content can be embedded with the `raw` function.
  
  ## Compatible

  The `iodata` output stream uses the same `:safe` tagging as
  [Phoenix](https://hexdocs.pm/phoenix_html/Phoenix.HTML.html) and can be directly
  called in views without `escape_html`.

  ## Example

      iex> import Kernel, except: [div: 2]
      ...> import Markaby
      ...> div do
      ...>    h1 do "Markaby" end
      ...>    h2 do "|> Elixir" end
      ...> end
      ...> |> escape_html
      ...> |> IO.iodata_to_binary
      "<div><h1>Markaby</h1><h2>|&gt; Elixir</h2></div>"

  ## Available tags

  * #{Enum.join(Enum.map(@sorted_tags, @link), ", ")}

  """

  @doc "Embed unsafe content directly in output."

  def raw(raw) do
    {:safe, raw}
  end

  @doc "Generate a tag with attributes and use the do block for nesting content."

  def tag(tag, attrs \\ %{}, do: block) do
    [start_tag(tag, attrs), block, end_tag(tag)]
  end

  defp start_tag(tag, attrs) do
    raw [?<, tag, attrs(attrs), ?>]
  end

  defp end_tag(tag) do
    raw [?<, ?/, tag, ?>]
  end

  defp attrs(attrs) do
    for {key, value} <- attrs do
      [?\s, Atom.to_string(key), ?=, ?", escape_html(value), ?"]
    end
  end

  @doc "Escapes textual content into HTML safe output."

  def escape_html({:safe, raw}),  do: raw

  def escape_html(nil),           do: []
  def escape_html(""),            do: []
  def escape_html("<"   <> rest), do: ["&lt;"   | escape_html(rest)]
  def escape_html(">"   <> rest), do: ["&gt;"   | escape_html(rest)]
  def escape_html("\""  <> rest), do: ["&quot;" | escape_html(rest)]
  def escape_html("&"   <> rest), do: ["&amp;"  | escape_html(rest)]
  def escape_html(<<c>> <> rest), do: [c        | escape_html(rest)]

  def escape_html([]),            do: []
  def escape_html([head | tail]), do: [escape_html(head) | escape_html(tail)]

  @doc false
  defmacro content(do: {:__block__, _, content}), do: content
  defmacro content(do: expr), do: expr

  for mytag <- @tags do  
    @doc false
    defmacro unquote(mytag)(attrs \\ quote(do: %{}), do: block) do
      mytag = unquote(Atom.to_string(mytag))
      quote do
        tagcontent = content(do: unquote(block))
        tag(unquote(mytag), unquote(attrs), do: tagcontent)
      end
    end
  end

  for tag <- @empty_tags do
    @doc false
    def unquote(tag)(attrs \\ %{}) do
      if attrs[:do] do
        raise ArgumentError, "do block is invalid for empty tag"
      end
      start_tag(unquote(Atom.to_string(tag)), attrs)
    end
  end
end
