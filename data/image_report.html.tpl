<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title></title>
        <link href="fonts/font-awesome/css/font-awesome.css" rel="stylesheet">
        <link href="fonts/font-spacewalk/css/spacewalk-font.css" rel="stylesheet">
        <link href="css/spacewalk.less" rel="stylesheet/less">
        <script src="javascript/jquery.js"></script>
        <script src="javascript/bootstrap.js"></script>
        <script src="javascript/less.js"></script>

        <script>
          $(document).ready(function() {
            $(".collapse").collapse();
          });
        </script>
    </head>
    <body>

    <div class="panel-group" id="accordion">
    <%  image_ocurr.sort_by {|_key, value| -1 * image_rank[_key] }.each do  |tuple|
          image = tuple[0]
          icon = image_map[image]
          path = File.join(images_directory, image)
          next if not File.exist?(path)
          data = Base64.encode64(File.read(path))

          src = case File.extname(image)
            when '.gif' then "data:image/gif;base64,#{data}"
            when '.png' then "data:image/png;base64,#{data}"
            else ''
          end

          img_size = FastImage.size(path)
          font_em = img_size.max / 16.0 rescue 1
          panel_class = if image_rank[image] > 0 && (icon.nil? || icon.empty?)
            'panel-danger'
          elsif image_rank[image] == 0
            'panel-info'
          else
            'panel-default'
          end

    %>
      <div class="panel <%= panel_class %>">
        <div class="panel-heading">
            <h4 class="panel-title">
            <a data-toggle="collapse" data-parent="#accordion" href="#collapse-<%= image.hash %>"><span class="badge"><%= image_rank[image] %></span> <%= image %> </a>
            </h4>

              <img src="<%= src %>"/> <i style="font-size: <%= font_em %>em;" class="fa <%= icon %>"></i>

        </div>
        <div id="collapse-<%= image.hash %>" class="panel-collapse collapse">
          <div class="panel-body">
            <ul>
            <% image_ocurr[image].each do |file| %>
              <li><a href="file:/<%= File.expand_path(file) %>"><%= file %></a></li>
            <% end %>
            </ul>

          </div>
        </div>
      </div>
      <% end %>
    </div>

    </body>
</html>