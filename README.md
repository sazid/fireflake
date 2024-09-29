# 🔥 Fireflake

Implementation of [Snowflake ID](https://en.wikipedia.org/wiki/Snowflake_ID) for
Mojo 🔥.

<br />
<div align="center">
    <img style="border-radius: 100%; border: 2px solid rgba(0,0,0,0.05);" src="static/logo.jpg" alt="Logo" width="200" height="200">

  <h3 align="center">🔥 Fireflake</h3>

  <p align="center">

   ![Written in Mojo][language-shield]
   [![Apache-2.0 license][license-shield]][license-url]
   ![Build status][build-shield]
   <br/>
   [![Contributors Welcome][contributors-shield]][contributors-url]
  </p>
</div>

## Getting started

1. 🌩️ Download `fireflake.mojopkg` from [releases](https://github.com/sazid/fireflake/releases).
2. 🗄️ Place it in your project working directory. 
3. 📝 Follow the usage guideline below.

## Usage

```python
from fireflake import Fireflake

fn main() raises:
    # Generate new id with default config - Twitter/X style Snowflake ID.
    fireflake = Fireflake()
    new_id = fireflake.generate()
    print(new_id)

    # Generate new id with custom config for nodes/sequence bit count.
    fireflake2 = Fireflake[node_bits_count=7, sequence_bits_count=15]()
    new_id = fireflake2.generate()
    print(new_id)

    # Generate new id with default config but provide a custom number - which
    # could be hash of your data or any other meaningful number you select.
    fireflake3 = Fireflake()
    new_id = fireflake3.generate(1234)
    print(new_id)
```

### Check out other Mojo libraries:

- HTTP framework - [@saviorand/lightbug_http](https://github.com/saviorand/lightbug_http)
- Logging - [@toasty/stump](https://github.com/thatstoasty/stump)
- CLI and Terminal - [@toasty/prism](https://github.com/thatstoasty/prism), [@toasty/mog](https://github.com/thatstoasty/mog)
- Date/Time - [@mojoto/morrow](https://github.com/mojoto/morrow.mojo) and [@toasty/small-time](https://github.com/thatstoasty/small-time)


[build-shield]: https://img.shields.io/github/actions/workflow/status/sazid/fireflake/.github%2Fworkflows%2Fpackage.yml
[language-shield]: https://img.shields.io/badge/language-mojo-orange
[license-shield]: https://img.shields.io/github/license/sazid/fireflake?logo=github
[license-url]: https://github.com/sazid/fireflake/blob/main/LICENSE
[contributors-shield]: https://img.shields.io/badge/contributors-welcome!-blue
[contributors-url]: https://github.com/sazid/fireflake#contributing
[discord-url]: https://discord.gg/VFWETkTgrr
