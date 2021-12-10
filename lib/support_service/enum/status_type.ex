defmodule SupportService.Enum.StatusType do
  defstruct [
    new: 1,
    ready: 2,
    working: 3,
    progress: 4,
    suspended: 5,
    stopped: 6,
    reviewing: 7,
    penalty: 8,
    incomplete: 9,
    complete: 10,
    active: 11,
    inactive: 12
  ]
end
