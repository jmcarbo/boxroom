try
{
    var IE = (navigator.userAgent.toLowerCase().indexOf("msie") != -1 ? true : false);
}
catch(e)
{
    var IE = false;
}

// Resizes the content div to the appropriate size.
// Should only be needed for IE
function ResizeContentDiv()
{
    var winHeight = window.innerHeight;
    if(winHeight == undefined){ winHeight = document.body.clientHeight; }

    if(winHeight > 0)
    {
        document.getElementById('middle').style.height = ( winHeight - 156 );
    }
}

// Unfortunately SlideDown does not work in IE,
// hence this implementation.
// Show the properties of the folder
function ShowProperties()
{
    if(IE)
    {
        Element.hide('list');
        Element.show('folder_rights');
    }
    else
    {
        new Effect.SlideUp('list', {queue: 'front'});
        new Effect.SlideDown('folder_rights', {queue: 'end'});
    }
    Element.show('list_link');
    Element.hide('rights_link');
    return false;
}

// Show the sub-folders and files in a folder
function ShowList()
{
    if(IE)
    {
        Element.hide('folder_rights');
        Element.show('list');
    }
    else
    {
        new Effect.SlideUp('folder_rights', {queue: 'front'});
        new Effect.SlideDown('list', {queue: 'end'});
    }
    Element.show('rights_link');
    Element.hide('list_link');
    return false;
}

// Create, Update and Delete is only possible when Reading is allowed too.
// By using this function onclick of the Read checkbox, you make sure that if
// Reading is not allowed Create, Update and Delete is not allow either.
function UncheckCreateUpdateDelete(checked, group)
{
    if(!checked)
    {
        eval("document.getElementById('create_check_box_" + group + "').checked = false");
        eval("document.getElementById('update_check_box_" + group + "').checked = false");
        eval("document.getElementById('delete_check_box_" + group + "').checked = false");
    }
}

// By using this function onclick of the Create, Update and Delete checkbox,
// you make sure that if Create, Update and Delete is allowed, Reading is allowed too.
function CheckRead(checked, group)
{
    if(checked)
    {
        eval("document.getElementById('read_check_box_" + group + "').checked = true");
    }
}

// Javascript framework
// for upload progress.
var UploadProgress = {
  uploading: null,
  monitor: function(upid) {
    if(!this.periodicExecuter) {
      this.periodicExecuter = new PeriodicalExecuter(function() {
        if(!UploadProgress.uploading) return;
        new Ajax.Request('/file/progress?upload_id=' + upid);
      }, 3);
    }

    this.uploading = true;
    this.StatusBar.create();
  },

  update: function(total, current) {
    if(!this.uploading) return;
    var status     = current / total;
    var statusHTML = status.toPercentage();
    $('results').innerHTML   = statusHTML + "<br /><small>" + current.toHumanSize() + ' of ' + total.toHumanSize() + " uploaded.</small>";
    this.StatusBar.update(status, statusHTML);
  },
  
  finish: function(return_url) {
    this.uploading = false;
    this.StatusBar.finish();
    $('results').innerHTML = 'finished!';
    window.parent.location.href = return_url;
  },
  
  cancel: function(msg) {
    if(!this.uploading) return;
    this.uploading = false;
    if(this.StatusBar.statusText) this.StatusBar.statusText.innerHTML = msg || 'canceled';
  },
  
  StatusBar: {
    statusBar: null,
    statusText: null,
    statusBarWidth: 500,
  
    create: function() {
      Element.hide('initial-status');
      this.statusBar  = this._createStatus('status-bar');
      this.statusText = this._createStatus('status-text');
      this.statusText.innerHTML  = '0%';
      this.statusBar.style.width = '0';
    },

    update: function(status, statusHTML) {
      this.statusText.innerHTML = statusHTML;
      this.statusBar.style.width = Math.floor(this.statusBarWidth * status);
    },

    finish: function() {
      this.statusText.innerHTML  = '100%';
      this.statusBar.style.width = '100%';
    },
    
    _createStatus: function(id) {
      el = $(id);
      if(!el) {
        el = document.createElement('span');
        el.setAttribute('id', id);
        $('progress-bar').appendChild(el);
      }
      return el;
    }
  },
  
  FileField: {
    add: function() {
      new Insertion.Bottom('file-fields', '<p style="display:none"><input id="data" name="data" type="file" /> <a href="#" onclick="UploadProgress.FileField.remove(this);return false;">x</a></p>')
      $$('#file-fields p').last().visualEffect('blind_down', {duration:0.3});
    },
    
    remove: function(anchor) {
      anchor.parentNode.visualEffect('drop_out', {duration:0.25});
    }
  }
}

Number.prototype.bytes     = function() { return this; };
Number.prototype.kilobytes = function() { return this *  1024; };
Number.prototype.megabytes = function() { return this * (1024).kilobytes(); };
Number.prototype.gigabytes = function() { return this * (1024).megabytes(); };
Number.prototype.terabytes = function() { return this * (1024).gigabytes(); };
Number.prototype.petabytes = function() { return this * (1024).terabytes(); };
Number.prototype.exabytes =  function() { return this * (1024).petabytes(); };
['byte', 'kilobyte', 'megabyte', 'gigabyte', 'terabyte', 'petabyte', 'exabyte'].each(function(meth) {
  Number.prototype[meth] = Number.prototype[meth+'s'];
});

Number.prototype.toPrecision = function() {
  var precision = arguments[0] || 2;
  var s         = Math.round(this * Math.pow(10, precision)).toString();
  var pos       = s.length - precision;
  var last      = s.substr(pos, precision);
  return s.substr(0, pos) + (last.match("^0{" + precision + "}$") ? '' : '.' + last);
}

// (1/10).toPercentage()
// # => '10%'
Number.prototype.toPercentage = function() {
  return (this * 100).toPrecision() + '%';
}

Number.prototype.toHumanSize = function() {
  if(this < (1).kilobyte())  return this + " Bytes";
  if(this < (1).megabyte())  return (this / (1).kilobyte()).toPrecision()  + ' KB';
  if(this < (1).gigabytes()) return (this / (1).megabyte()).toPrecision()  + ' MB';
  if(this < (1).terabytes()) return (this / (1).gigabytes()).toPrecision() + ' GB';
  if(this < (1).petabytes()) return (this / (1).terabytes()).toPrecision() + ' TB';
  if(this < (1).exabytes())  return (this / (1).petabytes()).toPrecision() + ' PB';
                             return (this / (1).exabytes()).toPrecision()  + ' EB';
}