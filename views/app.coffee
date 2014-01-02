margin = 4

aspect_ratio = (photo) ->
  photo.width / photo.height

resize_and_add_images = (photos) ->
  img_container = $ "#img-container"
  viewport_width = window.innerWidth - margin
  ideal_height = parseInt (window.innerHeight - margin) / 2
  summed_width = _.reduce photos, ((sum, p) -> sum += aspect_ratio(p) * ideal_height), 0
  rows = Math.ceil summed_width / viewport_width
   
  if rows < 1
    # (2a) Fallback to just standard size 
    photos.each (photo) -> photo.view.resize parseInt(ideal_height * aspect_ratio(photo)), ideal_height
  else
    # (2b) Distribute photos over rows using the aspect ratio as weight
    weights = _.map photos, (p) -> parseInt(aspect_ratio(p) * 100)
    p2 = _.map photos, (p) ->
      ar = aspect_ratio p
      {
        p: p
        ar: ar
        ideal_width: ar * ideal_height
      }
    
    partitions = linear_partition(weights, rows)

    # (3) Iterate through partition
    index = 0
    _.each partitions, (row) ->
      row_buffer = []
      _.each row, -> row_buffer.push(photos[index++])
      summed_ratios = _.reduce row_buffer, ((sum, p) -> sum += aspect_ratio p), 0
      _.each row_buffer, (photo) ->
        div = $ " <div class='img' />"
        div.css {"backgroundImage": 'url("' + photo.src + '")'}
        div.width parseInt(viewport_width / summed_ratios * aspect_ratio photo) - margin
        div.height parseInt(viewport_width / summed_ratios) - margin
        img_container.append div

$().ready ->
  
  queue = 0
  photos = _.map window.images, (path) ->
    img = new Image()
    img.src = path
    queue++;
    img.onload = () ->
      queue--;
      if queue == 0
        resize_and_add_images photos
    img

  


  
