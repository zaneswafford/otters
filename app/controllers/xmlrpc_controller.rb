class XmlrpcController < ApplicationController
  #before_filter :disable_xss_protection, only: :xe_index
  protect_from_forgery :except => :xe_index 
  
  # XML-RPC for MarsEdit
  exposes_xmlrpc_methods :method_prefix => "metaWeblog."
  
  def getPost(postid, username, password)
    if User.find_by(name: username).try(:authenticate, password)
      article = Article.find(postid.to_i)
      hash = { title: article.title, 
            description: article.text,
            link: 'http://otters.io/' + article.id,
            post_status: if article.is_published then 'published' else 'draft' end,
            date_created: article.created_at.utc.iso8601,
            date_modified: article.updated_at.utc.iso8601,
            categories: '',
            mt_keywords: '',
            mt_excerpt: '',
            mt_text_more: '' }
      return hash
    end
  end
  
  def newPost(blogid, username, password, content, publish) 
    if User.find_by(name: username).try(:authenticate, password) 
      article = Article.new( title: content["title"], 
                             text: content["description"], 
                             is_published: publish)
      
      if article.save
        article.id
      end
    end
  end
  
  def getRecentPosts(blogid, username, password, numberOfPosts)
    if User.find_by(name: username).try(:authenticate, password)
      numberOfArticles ||= 10
      articles = Article.order('created_at DESC, updated_at DESC').limit(numberOfPosts)
      arr = []
      articles.each do |article|
        hash = { 
              postid: article.id.to_s, 
              title: article.title, 
              description: article.text,
              link: 'http://otters.io/' + article.id.to_s,
              post_status: if article.is_published then 'published' else 'draft' end,
              date_created: article.created_at.utc.iso8601,
              date_modified: article.updated_at.utc.iso8601,
              categories: '',
              mt_keywords: '',
              mt_excerpt: '',
              mt_text_more: '' }
        arr.push hash
      end
      
      arr
    end
  end
  
  def editPost(postid, username, password, content, publish)
    if User.find_by(name: username).try(:authenticate, password) 
      Article.update(postid.to_i, 
        title: content["title"], 
        text: content["description"],
        is_published: publish)
    return true
    end
  end
  
  def deletePost(appkey, postid, username, password, publish) 
    if User.find_by(name: username).try(:authenticate, password) 
      Article.delete(postid.to_i)
      return true
    end
  end
    
  def getCategories(blogid, username, password) 
    if User.find_by(name: username).try(:authenticate, password)
      # Categories are not available
      return []
    end
  end
  
  def newMediaObject(blogid, username, password, data) 
    #
  end
  
  def getUsersBlogs(appkey, username, password) 
    if authenticate_xml_rpc(username, password) 
      return [{ blogid: "1", 
                url: "http://otters.io", 
                blogName: "Otters" }]
    end
  end
  
end
