!function(){var n={},t=function(t){for(var e=n[t],i=e.deps,a=e.defn,o=i.length,u=new Array(o),l=0;l<o;++l)u[l]=r(i[l]);var c=a.apply(null,u);if(void 0===c)throw"module ["+t+"] returned undefined";e.instance=c},e=function(t,e,r){if("string"!=typeof t)throw"module id must be a string";if(void 0===e)throw"no dependencies for "+t;if(void 0===r)throw"no definition function for "+t;n[t]={deps:e,defn:r,instance:void 0}},r=function(e){var r=n[e];if(void 0===r)throw"module ["+e+"] was undefined";return void 0===r.instance&&t(e),r.instance},i=function(n,t){for(var e=n.length,i=new Array(e),a=0;a<e;++a)i[a]=r(n[a]);t.apply(null,i)};({}).bolt={module:{api:{define:e,require:i,demand:r}}};var a=e;(function(n,t){a(n,[],function(){return t})})("3",tinymce.util.Tools.resolve),a("1",["3"],function(n){return n("tinymce.PluginManager")}),a("4",["3"],function(n){return n("tinymce.util.Tools")}),a("5",[],function(){return{getNonEditableClass:function(n){return n.getParam("noneditable_noneditable_class","mceNonEditable")},getEditableClass:function(n){return n.getParam("noneditable_editable_class","mceEditable")},getNonEditableRegExps:function(n){var t=n.getParam("noneditable_regexp",[]);return t&&t.constructor===RegExp?[t]:t}}}),a("2",["4","5"],function(n,t){var e=function(n){return function(t){return-1!==(" "+t.attr("class")+" ").indexOf(n)}},r=function(n,t,e){return function(r){var i=arguments,a=i[i.length-2],o=a>0?t.charAt(a-1):"";if('"'===o)return r;if(">"===o){var u=t.lastIndexOf("<",a);if(-1!==u&&-1!==t.substring(u,a).indexOf('contenteditable="false"'))return r}return'<span class="'+e+'" data-mce-content="'+n.dom.encode(i[0])+'">'+n.dom.encode("string"==typeof i[1]?i[1]:i[0])+"</span>"}},i=function(n,e,i){var a=e.length,o=i.content;if("raw"!==i.format){for(;a--;)o=o.replace(e[a],r(n,o,t.getNonEditableClass(n)));i.content=o}};return{setup:function(r){var a,o,u="contenteditable";a=" "+n.trim(t.getEditableClass(r))+" ",o=" "+n.trim(t.getNonEditableClass(r))+" ";var l=e(a),c=e(o),d=t.getNonEditableRegExps(r);r.on("PreInit",function(){d.length>0&&r.on("BeforeSetContent",function(n){i(r,d,n)}),r.parser.addAttributeFilter("class",function(n){for(var t,e=n.length;e--;)t=n[e],l(t)?t.attr(u,"true"):c(t)&&t.attr(u,"false")}),r.serializer.addAttributeFilter(u,function(n){for(var t,e=n.length;e--;)t=n[e],(l(t)||c(t))&&(d.length>0&&t.attr("data-mce-content")?(t.name="#text",t.type=3,t.raw=!0,t.value=t.attr("data-mce-content")):t.attr(u,null))})})}}}),a("0",["1","2"],function(n,t){return n.add("noneditable",function(n){t.setup(n)}),function(){}}),r("0")()}();