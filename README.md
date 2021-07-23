# Refmon

Refmon is an Elixir implementation of a reference monitor.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `refmon` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:refmon, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/refmon](https://hexdocs.pm/refmon).

## Usage

### カーネルへの組み込み

Refmon.validateマクロをアクセスする層に呼び出す。

例:

```elixir
def some_access_function() do
    validate("User1", "Target1", :read, nil)
    |> case do
        :deny -> raise PermissionError
        :allow -> nil
       end
end
```

### Adapterの実装

Refmon.Adapter ビヘイビアを実装する。

例:

```elixir
defmodule MyApp.MyAdapter do
  use Refmon.Adapter

  def permission(subj, obj, acc, param) do
    case {subj, obj, acc, param} do
      {_, _, :use, "exclusive"} -> :deny
      {"I", "my " <> _, _, _} -> :allow
      {"he", "his " <> _, _, _} -> :allow
      {"subj", "obj", _, _, _} -> :allow
      _ -> :deny
    end
  end
end
```

permission は、アクセス主体 subj とターゲット obj, アクセスモード acc、
アクセスモードパラメータ param をパラメータとして呼び出されるので、許
可(:allow) か 禁止 (:deny) を返す。

permission の呼び出し結果は、Refmon 側でキャッシュされる。キャッシュを
クリアするのは、アプリケーションモジュールの責任である。


subject が nil の場合、システム呼び出しとみなされ、permission は呼び出
されない。

Refmon を組み込むアプリケーションの config.exs に アダプタモジュールを
設定する。

```elixir
config :refmon,
  adapter: MyApp.MyAdapter
```
