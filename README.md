# Intial Setup

    docker-compose build
    docker-compose up mariadb
    # Once mariadb says it's ready for connections, you can use ctrl + c to stop it
    docker-compose run short-app rails db:migrate
    docker-compose -f docker-compose-test.yml build

# To run migrations

    docker-compose run short-app rails db:migrate
    docker-compose -f docker-compose-test.yml run short-app-rspec rails db:test:prepare

# To run the specs

    docker-compose -f docker-compose-test.yml run short-app-rspec

# Run the web server

    docker-compose up

# Adding a URL

    curl -X POST -d "full_url=https://google.com" http://localhost:3000/short_urls.json

# Getting the top 100

    curl localhost:3000

# Checking your short URL redirect

    curl -I localhost:3000/abc

# Algorithm

A short code is a sequence of characters that map **exactly** one-to-one with an ID of a record in a table within the database. From an API viewpoint, a user that provides a given short code can be redirected to the full URL stored within the record identified by the ID that the short code maps to. For this project, short codes are represented in base62 with the set of characters that includes the following: 0-9, a-z, and A-Z. As can be seen in the table below, the expanded character set of short codes allow for bigger numbers to be represented with less characters relative to the integer ID equivalent. This is important, because a user will provide a short code in a request to the web server instead of an ID which helps shorten the length of the URL in the request.

* NOTE: For this project, 0 was omitted due to the fact that tables in MariaDB can not be re-configured to start at a value below 1.

| Integer (base10) | Short Code (base62) |
| :--------------: | :-----------------: |
|        1         |         "1"         |
|       ...        |         ...         |
|       62         |        "10"         |
|       ...        |        ...          |
|      6291        |        "1Dt"        |
|       ...        |        ...          |
|     14776335     |       "ZZZZ"        |
|       ...        |        ...          |

Encoding and decoding methods were implemented to convert between integers and short codes when the user makes a request. The methods were implemented in such a way that they are inverse to each other (see bullet points below) on the set of all integers from 1 to ∞ and short codes from "1" to "∞". Technically, the methods could be modified to start at 0. However, that would require additional operations which would be inefficient for the benefit of only one additional integer and short code mapping. This would also break the tests which are functionally not supposed to change.

* encode(decode(str)) = str

* decode(encode(num)) = num

## Encoding

The encoding method is processed when a valid request is made to the POST / endpoint. The ID of the associated ShortUrl object is passed as input to the encoding method (which as stated before will always be a positive integer). The following steps describe how this works.

1. A string variable is assigned a value of an empty string which is used for constructing and storing the short code.

2. A loop starts and evaluates whether the num is positive. If it is positive, then the following sub-steps occur.

    1. The remainder of the division between num and 62 (base62) is returned.

    2. The remainder is used to find a character within the CHARACTERS array at the specified index.

    3. The character is prepended to the string variable.

    4. num is divided by 62 (base62) and the output of that expression is used to re-reassign num.

    5. The loop repeats. The loop will end once num is 0 which means that it can no longer be divided.

3. The string short code is returned.

NOTE: The POST / endpoint returns this string to the user in the response.

## Decoding

The decoding method is processed when a valid request is made to the GET /:id endpoint. The short code that the user passes is processed as input to the decoding method. The following steps describe how this works.

1. The num variable is assigned a value of 0.

2. A loop starts and passes each character (left-to-right) iteratively to the block for processing.

    1. num is multipled by 62 (base62).

    2. The index of a character is found within the CHARACTERS array.

    3. The index is added to the output of the multiplication between num and 62.

    4. num is re-assigned.

    5. The loop continues if another character exists within str.

3. After all characters have been processed, num is returned.

NOTE: This num is used to query for a record within the short_urls table in the database. If found, the record's click_count gets updated and the user is redirected to the full URL associated with the record.

# Considerations

* It could be beneficial to create a descending index on the click_count column to improve performance for when the user attempts to retrieve the top 100 most frequently accessed short codes. This would depend on the frequency of updates to click_count versus the frequency of the requests to the top 100 most frequencly accessed short codes endpoint as well as the number of rows already within the table.

* If implemented correctly, a caching implementation would improve response times from the index endpoint as well.

# Comments

* The 'has a list of the top 100 urls' spec test contained a reference to 'urls' and the challenge notes suggested that the index route should return the top 100 most frequently accessed short codes. As a result, I adhered to the challenge despite this discrepency.

* I did some research and identified that a :moved_permanently status is what popular URL shorteners like bit.ly return for the redirection HTTP status code.
