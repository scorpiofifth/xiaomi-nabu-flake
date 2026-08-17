(final: prev: {
  upower = prev.upower.overrideAttrs (oldAttrs: {
    patches = oldAttrs.patches ++ [
      ./no-negative-current-check.patch
    ];
  });
})
