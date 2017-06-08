Alternative Text notes
The program generates alternative text for images on a webpage, making
the site more accessible to the visually impaired that rely on screen
readers such as JAWS.

The program uses Ruby's Nokogiri gem to parse the HTML, grabbing the
images on the webpages. Images are uploaded to a request to
Google Cloud's Vision API, which derives insight and generates a description,
which will populate the alternative text attribute for the image tag on
the webpage.

The program first uses the API's Label Detection broadly categorizes the
images, determining. If the labels indicate a person, text, or a painting,
the program uses a more targeted search, such as optical character
recognition for text or landmark detection for places, to generate meaningful text. T
