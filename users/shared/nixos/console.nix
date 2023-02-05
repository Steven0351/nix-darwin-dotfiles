{ pkgs
, lib
, inputs
, config
, ...
}: {
  console =
    let
      normal = [ "181825" "F38BA8" "A6E3A1" "F9E2AF" "89B4FA" "F5C2E7" "94E2D5" "BAC2DE" ];
      bright = [ "1E1E2E" "F38BA8" "A6E3A1" "F9E2AF" "89B4FA" "F5C2E7" "94E2D5" "A6ADC8" ];
    in
    {
      colors = normal ++ bright;
      keyMap = "us";
    };
}
