class HomeController < ApplicationController
  def index
    @updated_at = Update.order('updated_at DESC').first.updated_at
    @data = Document.all

    d = params[:d]
    d = '@' if d.nil? or d.empty?
    startdate = d.split('@')[0]
    enddate = d.split('@')[1]
    @data = @data.where("uploaded_at >= ?", DateTime.parse(startdate).beginning_of_day) unless startdate.nil? or startdate.empty?
    @data = @data.where("uploaded_at <= ?", DateTime.parse(enddate).end_of_day) unless enddate.nil? or enddate.empty?

    q = params[:q]
    q = '' if q.nil?
    queries = q.split(',')
    queries.each {|query| @data = @data.where("name like ?", "%#{query}%")}

    b = params[:b]
    b = '1111' if b.nil? || b.empty?
    location = ['공지사항', '가정통신문', '자료실', '대회안내']
    b.split('').each_with_index {|l, i| @data = @data.where.not(:location => location[i]) if l.eql? '0'}
    @data = @data.order('uploaded_at DESC').page(params[:page]).per(20)
  end
  def download
    send_file '../files/' + params[:q]
  end
end
