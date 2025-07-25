defmodule Tuist.Projects.Project do
  @moduledoc """
  A module that represents projects.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Tuist.Accounts.Account
  alias Tuist.Accounts.User
  alias Tuist.AppBuilds.Preview

  @derive {
    Flop.Schema,
    filterable: [:account_id, :name], sortable: [:name, :created_at], default_limit: 20
  }

  schema "projects" do
    field :token, :string
    field :name, :string
    field :visibility, Ecto.Enum, values: [private: 0, public: 1], default: :private
    field :default_branch, :string, default: "main"
    field :vcs_repository_full_handle, :string
    field :vcs_provider, Ecto.Enum, values: [github: 0]
    field :last_interacted_at, :naive_datetime, virtual: true

    belongs_to :account, Account

    has_many :previews, Preview

    has_many :users_with_last_visited_projects, User,
      foreign_key: :last_visited_project_id,
      foreign_key: :last_visited_project_id,
      on_delete: :nilify_all

    # Rails names the field "created_at"
    # credo:disable-for-next-line Credo.Checks.TimestampsType
    timestamps(inserted_at: :created_at)
  end

  def create_changeset(project \\ %__MODULE__{}, attrs) do
    project
    |> cast(attrs, [
      :token,
      :account_id,
      :name,
      :created_at,
      :visibility,
      :vcs_repository_full_handle,
      :vcs_provider
    ])
    |> validate_allowed_handle()
    |> validate_inclusion(:visibility, [:private, :public])
    |> validate_inclusion(:vcs_provider, [:github])
    |> validate_required([:token, :account_id, :name])
    |> validate_change(:name, fn :name, name ->
      if String.contains?(name, ".") do
        [
          name:
            "Project name can't contain a dot. Please use a different name, such as #{String.replace(name, ".", "-")}."
        ]
      else
        []
      end
    end)
    |> update_change(:name, &String.downcase/1)
    |> unique_constraint([:name, :account_id], name: "index_projects_on_name_and_account_id")
  end

  def validate_allowed_handle(changeset) do
    validate_exclusion(changeset, :name, Application.get_env(:tuist, :blocked_handles))
  end

  def update_changeset(project, attrs) do
    project
    |> cast(attrs, [:default_branch, :vcs_repository_full_handle, :vcs_provider, :visibility])
    |> validate_inclusion(:vcs_provider, [:github])
    |> validate_inclusion(:visibility, [:private, :public])
  end
end
