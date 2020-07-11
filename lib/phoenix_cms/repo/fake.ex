defmodule PhoenixCms.Repo.Fake do
  @moduledoc false

  alias PhoenixCms.{Article, Content, Repo}

  @behaviour Repo

  @impl Repo
  def all(Content) do
    {:ok,
     [
       %PhoenixCms.Content{
         content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
         id: "contents-1",
         image:
           "https://dl.airtable.com/.attachments/563ecc87aafc8e4d45538c8ea317d327/3c929f5a/shoes.png",
         position: 11,
         styles: "",
         title: "Feature 5",
         type: "feature"
       },
       %PhoenixCms.Content{
         content:
           "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Netus et malesuada fames ac turpis egestas.",
         id: "contents-2",
         image:
           "https://dl.airtable.com/.attachments/35df37eac0fbc295abcc65b4b1cba655/71d5e205/safari.png",
         position: 3,
         styles: "",
         title: "I'm baby helvetica air ",
         type: "text_and_image"
       }
     ]}
  end

  def all(Article) do
    {:ok,
     [
       %Article{
         author: "author-1@phoenixcms.com",
         content:
           "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Netus et malesuada fames ac turpis egestas.\n",
         description:
           "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Netus et malesuada fames ac turpis egestas.\n",
         id: "article-1",
         image:
           "https://dl.airtable.com/.attachments/b7a0bafdbb46af7fe860ff4e799abf3b/5b2879ef/image-1.jpg",
         published_at: ~D[2020-06-27],
         slug: "lorem-ipsum",
         title: "Lorem ipsum dolor sit amet"
       },
       %Article{
         author: "author-1@phoenixcms.com",
         content:
           "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Netus et malesuada fames ac turpis egestas.\n",
         description:
           "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Netus et malesuada fames ac turpis egestas.\n",
         id: "article-2",
         image:
           "https://dl.airtable.com/.attachments/b7a0bafdbb46af7fe860ff4e799abf3b/5b2879ef/image-1.jpg",
         published_at: ~D[2020-06-27],
         slug: "lorem-ipsum",
         title: "Lorem ipsum dolor sit amet"
       }
     ]}
  end

  def all(_), do: {:error, :not_found}

  @impl Repo
  def get(entity, id) when entity in [Article, Content] do
    with {:ok, items} <- all(entity),
         {:ok, nil} <- {:ok, Enum.find(items, &(&1.id == id))} do
      {:error, :not_found}
    end
  end

  def get(_, _), do: {:error, :not_found}
end
