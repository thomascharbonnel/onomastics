# Ruby Onomastics

This project's goal is to try and evaluate the adequacy of an ANN to compute
relationships between a person's name and a place (a country, for now).

First, I recommend fetching some data from Wikipedia. It'd possible to make use
of [Wikidata Query Service](https://query.wikidata.org/) if it weren't for the
response's size limit. Damn. :passport_control:

So, best way to do this? Just download all of Wikipedia. Enjoy 84 GB of knowledge. :sunglasses:
Or… there is an alternative?
Well, kind of.

## Downloading Wikipedia for Fun and Profit

I'm too lazy to write code when somebody already did their part. :cat2:
My thanks go to @maxlath for [Wikidata filter](https://github.com/maxlath/wikidata-filter).
Install it first, through `npm`. Then, clone this repository.

```bash
git clone https://github.com/thomascharbonnel/onomastics
```

Finally, run:

```bash
curl https://dumps.wikimedia.org/wikidatawiki/entities/latest-all.json.bz2 | gzip -d | wikidata-filter --languages en --claim P31:Q5 P27 --keep labels,claims | ./parse_wikidata.rb > training_set.txt
```

The resulting file is around 45 MB (Sept. 24, 2016). Its format is quite awesome :exclamation:

```text
<first name 1> <first name 2> ... <last name>,["<ID for country 1>", "<ID for country 2>", ...]
```

With that, we can do some serious work. :guitar: :star2:

## Processing the Data with a Marvelous ANN

*Good things come to those who wait.*
