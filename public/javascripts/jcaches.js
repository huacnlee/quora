/**
 * jCaches - 数据缓存类
 * Author:  李华顺[http://huacn.blogbus.com]<huacnlee@gmail.com>
 * Version: 0.2
 * Project: http://code.google.com/p/jcaches/
 * License: GNU General Public License v3 [http://www.gnu.org/licenses/gpl.html]
 * @param {Number} cacheLength 最大限制存几个缓存项
 * @param {Boolean} isDebug 是否开启调试，这项只可以在Firefox下设true
 * @param {Array[JSON Object]} initDatas 初始化 cacheData的数据,此参数用载入旧的数据
 */
var jCaches = function(cacheLength,isDebug,initDatas){

    var cacheData = [];
    if(initDatas != undefined && initDatas != null){
	    cacheData = initDatas;	    
	}
	
	/* 自增,只会越来越大，用在调用者不传ID的情况做唯一编号 */
	var autoIncreaseID = 0;
	
	/**
	 * 刷新公开的变量的值
	 */
	var refreshPublicMemberValue = function(obj){	
	    obj.length = obj.size();
	    obj.datas = cacheData;
	}
	
	/** 以下是公开的成员 **/
	
	/**
	 * 缓存的数据数组列表，只读，修改它不会影响原数据
	 */
	this.datas = [];
	
	/**
	 * 目前已存放的个数
	 */
	this.length = 0;
	
	/**
	 * 得到目前的缓存个数
	 */
	this.size = function(){
	    this.length = cacheData.length;
	    return this.length;
	}
	
	/**
	 * 添加
	 * @param {String} id 标识ID,自动编号请传null
	 * @param {Object} value 值
	 */
	this.add = function(id, value){
        
        /* 处理只有一个参数的请 */
        if(id == null){
            autoIncreaseID ++;
            id = autoIncreaseID;            
        }

		/* 检查是否存在，有的话就不存 */
		if (this.exist(id)) {
			if (isDebug) {
				console.log("cache existed.");
			}
			return ;
		}

		/* 如果满了，就删除第一个 */
		if(cacheData.length > cacheLength){
			var oldItem = cacheData[0];
			cacheData.shift();
			var newItem = cacheData[0];
			if(isDebug){
				console.log("old first id:" +oldItem.id);
				console.log("new first id:" +newItem.id);
			}
		}
		
		if(isDebug){
			console.log("cache size:" + cacheData.length);
		}		
		
		/* 向缓存数据添加一项 */
		cacheData.push({id:id,value : value});
	
	    //refresh
	    refreshPublicMemberValue(this);

        return id;
	}
	
	/**
	 * 根据“标识ID”删除缓存信息
	 * @param {String} id 标识ID
	 */
	this.remove = function(id){
	    for(var i = 0; i < this.length ; i++){
	        if(cacheData[i].id == id){
	            cacheData.splice(i,1);
	            
	            //refresh
	            refreshPublicMemberValue(this);
	    
	            return ;
	        }
	    }
	    
	}
	
	/**
	 * 根据“标识ID”检查缓存是否存在
	 * @param {String} id 标识ID
	 */
	this.exist = function(id){

		/* 通过循环找ID是否存在 */
		for(var i = 0; i < cacheData.length; i++){
			var item = cacheData[i];
			if(item.id == id){
				if(	isDebug){				
					console.log("found an exist item: " + item.id);
				}
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * 取缓存
	 * @param {String} id 标识ID
	 */
	this.get = function(id){

		for(var i = 0; i < cacheData.length; i++){
			var item = cacheData[i];
			if(item.id == id){
				return item.value;
			}
		}
		return null;
	}
	
	/**
	 * 清空缓存
	 */
	this.clear = function(){
	
		cacheData =  new Array();
		
		//refresh
	    refreshPublicMemberValue(this);
	}
	
	/**
	 * 遍历Cache列表
	 * @param {event} callback 回调函数,带有一个参数返回，是当前Cache的value
	 */
	this.each = function(callback){
	    for(var i = 0; i < cacheData.length; i++){
	        callback(cacheData[i].value);
	    }
	}
	
	refreshPublicMemberValue(this);

};


