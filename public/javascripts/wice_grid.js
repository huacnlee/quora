function WiceGridProcessor(name, base_request_for_filter, base_link_for_show_all_records,
                      link_for_export, parameter_name_for_query_loading, parameter_name_for_focus, environment){

   this.checkIfJsFrameworkIsLoaded = function(){
     if (! jQuery){
       alert("jQuery not loaded, WiceGrid cannot proceed!")
     }
   }

  this.checkIfJsFrameworkIsLoaded();
  this.name = name;
  this.parameter_name_for_query_loading = parameter_name_for_query_loading;
  this.parameter_name_for_focus = parameter_name_for_focus;
  this.base_request_for_filter = base_request_for_filter;
  this.base_link_for_show_all_records = base_link_for_show_all_records;
  this.link_for_export = link_for_export;
  this.filter_declarations = new Array();
  this.environment = environment;

  this.toString = function(){
    return "<WiceGridProcessor instance for grid '" + this.name + "'>";
  }


  this.process = function(dom_id_to_focus){
    window.location = this.build_url_with_params(dom_id_to_focus);
  }

  this.reload_page_for_given_grid_state = function(grid_state){
    var request_path = this.grid_state_to_request(grid_state);
    window.location = this.append_to_url(this.base_link_for_show_all_records, request_path);
  }

  this.load_query = function(query_id){
    var request = this.append_to_url(this.build_url_with_params(),
      (this.parameter_name_for_query_loading +  encodeURIComponent(query_id)));
    window.location = request;
  }

  this.save_query = function(query_name, base_path_to_query_controller, grid_state, input_ids){
    if (input_ids instanceof Array) {
      input_ids.each(function(dom_id){
        grid_state.push(['extra[' + dom_id + ']', $('#'+ dom_id)[0].value])
      });
    }

    var request_path = this.grid_state_to_request(grid_state);

    jQuery.ajax({
      url: base_path_to_query_controller,
      async: true,
      data: request_path + '&query_name=' + encodeURIComponent(query_name),
      dataType: 'script',
      type: 'POST'
    });
  }

  this.grid_state_to_request = function(grid_state){
    return jQuery.map(grid_state, function(pair){
      return encodeURIComponent(pair[0]) + '=' + encodeURIComponent(pair[1]);
    }).join('&');
  }


  this.append_to_url = function(url, str){
    var sep;
    if (url.indexOf('?') != -1){
      if (/[&\?]$/.exec(url)){
        sep = '';
      }else{
        sep = '&';
      }
    }else{
      sep = '?';
    }
    return url + sep + str;
  }


  this.build_url_with_params = function(dom_id_to_focus){
    var results = new Array();
    var _this =  this;
    jQuery.each(this.filter_declarations, function(i, filter_declaration){
      param = _this.read_values_and_form_query_string(
        filter_declaration.filter_name, filter_declaration.detached,
        filter_declaration.templates, filter_declaration.ids);
      if (param && param != ''){
        results.push(param);
      }
    });

    var res = this.base_request_for_filter;
    if ( results.length != 0){
      all_filter_params = results.join('&');
      res = this.append_to_url(res, all_filter_params);
    }
    if (dom_id_to_focus){
      res = this.append_to_url(res, this.parameter_name_for_focus + dom_id_to_focus);
    }
    return res;
  }

  this.reset = function(){
    window.location = this.base_request_for_filter;
  }

  this.export_to_csv = function(){
    window.location = this.link_for_export;
  }

  this.register = function(func){
    this.filter_declarations.push(func);
  }

  this.read_values_and_form_query_string = function(filter_name, detached, templates, ids){
    var res = new Array();
    for(i = 0; i < templates.length; i++){
      if($(ids[i]) == null){
        if (this.environment == "development"){
          message = 'WiceGrid: Error reading state of filter "' + filter_name + '". No DOM element with id "' + ids[i] + '" found.'
          if (detached){
            message += 'You have declared "' + filter_name +
              '" as a detached filter but have not output it anywhere in the template. Read documentation about detached filters.'
          }
          alert(message);
        }
        return '';
      }
      var el = $('#' + ids[i]);
      var val;
      if (el[0] && el[0].type == 'checkbox'){
        if (el[0].checked) val = 1;
      } else {
        val = el.val();
      }
      if (val instanceof Array) {
        for(j = 0; j < val.length; j++){
          if (val[j] && val[j] != "")
            res.push(templates[i] + encodeURIComponent(val[j]));
        }
      } else if (val &&  val != ''){
        res.push(templates[i]  + encodeURIComponent(val));
      }
    }
    return res.join('&');
  }

};

function toggle_multi_select(select_id, link_obj, expand_label, collapse_label) {
  var select = $('#' + select_id)[0];
  if (select.multiple == true) {
    select.multiple = false;
    link_obj.title = expand_label;
  } else {
    select.multiple = true;
    link_obj.title = collapse_label;
  }
}

WiceGridProcessor._version = '0.4.3';
