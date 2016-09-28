%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "web/"]
      },
      checks: [
        {Credo.Check.Refactor.PipeChainStart, false},
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Readability.MaxLineLength, ignore_definitions: true, ignore_specs: true}
      ]
    }
  ]
}
