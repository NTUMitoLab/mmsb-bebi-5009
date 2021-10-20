# Mathematical Modeling in Systems Biology

![GitHub repo size](https://img.shields.io/github/repo-size/NTUMitoLab/mmsb-bebi-5009) ![GitHub commit activity](https://img.shields.io/github/commit-activity/m/NTUMitoLab/mmsb-bebi-5009)

## Commands

### Install Julia dependencies without updating

Requires `julia` to be installed.

```bash
julia --project=docs/intro/ --color=yes -e 'using Pkg; Pkg.instantiate()'
julia --project=docs/mmsb/ --color=yes -e 'using Pkg; Pkg.instantiate()'
```

### Update Julia dependencies

Requires `julia` to be installed.

```bash
julia --project=docs/intro/ --color=yes -e 'using Pkg; Pkg.update()'
julia --project=docs/mmsb/ --color=yes -e 'using Pkg; Pkg.update()'
```

### Run all the notebooks locally

Requires
- Julia dependencies installed
- Jupyter `nbconvert`
- GNU `parallel`

```bash
find . -type f -name '*.ipynb' -print0 | parallel -0 -j$(nproc) jupyter nbconvert --to notebook --ExecutePreprocessor.timeout=600 --execute --inplace {}
```