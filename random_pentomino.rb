#Random Pentomino
#2022-12-31 @aoki_taichi
#https://twitter.com/nosiika/status/1609025773817724930

# Paint n*n cells in random order.
# As soon as 5 cells are connected, detect which of the 12 type of pentomino is made. (If more than 6 cells are connected, ignore and reset.)
# List the types of pentomino in order by their occurrence rate.

#ｎ×ｎのマス目をランダムに黒く塗っていく。
#黒マスが5マス繋がった段階でそれがペントミノ12種類の内のどれか調べる（6マス越えていたら無視してリセット）。
#できるペントミノをできやすい順に並べたら、どんな感じに並ぶだろう？

class RandomPentomino
    def initialize(n)
        @rnd=Random.new()
        @n=n
        @board=Array.new(n){Array.new(n,0)}
        @order=(0..(n*n-1)).to_a.shuffle(random: @rnd)
        @cluster_size=[]
        @cluster_size[0]=nil
    end
    def show_result
        print result
        puts
    end
    def result
        @order.each_with_index{|i,cnt|
            x=i % @n
            y=i/@n
            neighbour_cluster=neighbour_cluster(x,y)    
            #puts board_str
            #p [x,y]
            #puts neighbour_cluster 
            new_size=1+ neighbour_cluster.map{|e|@cluster_size[e[:id]]}.inject(0, :+)
            #return "exceeded 5" if new_size>5
            return cnt,[new_size] if new_size>5
            if new_size==1 then
                @board[y][x]=@cluster_size.size
                @cluster_size[@board[y][x]]=1
            else
                @cluster_size[merge_clusters(x,y,neighbour_cluster)]=new_size
                if new_size==5
                    generate_result(x,y)            
                    #return "occurred\n"+board_str(@result_board)+"\n"+@result_pentomino.to_s
                    return cnt,@result_pentomino
                end
            end
        }
        raise "not expected to reach here"
    end
    def neighbour_cluster(x,y)
        neighbour_cluster=[]
        neighbour_cluster << {id:@board[y][x+1], y:y, x:x+1} if x<@n-1
        neighbour_cluster << {id:@board[y][x-1], y:y, x:x-1} if x>0
        neighbour_cluster << {id:@board[y+1][x], y:y+1, x:x} if y<@n-1
        neighbour_cluster << {id:@board[y-1][x], y:y-1, x:x} if y>0
        neighbour_cluster.uniq!{|e|e[:id]}
        return neighbour_cluster.reject{|e|e[:id]==0}
    end
    def merge_clusters(x,y,neighbour_cluster)
        merge_id=neighbour_cluster.pop[:id]
        @board[y][x]=merge_id 
        neighbour_cluster.each{|e|
            swap_board(e[:id],merge_id,e[:x],e[:y])
            @cluster_size[e[:id]]=nil
        }
#        p "mid=#{merge_id}"
        return merge_id
    end
    def swap_board(old_id, new_id, x, y)
        return if @board[y][x]==new_id
        return if @board[y][x]==0
        raise "x=#{x},y=#{y} is #{@board[y][x]} but expecting #{old_id}" unless @board[y][x]==old_id
        @board[y][x]=new_id
        swap_board(old_id, new_id, x+1, y) if x<@n-1
        swap_board(old_id, new_id, x-1, y) if x>0
        swap_board(old_id, new_id, x, y+1) if y<@n-1
        swap_board(old_id, new_id, x, y-1) if y>0
    end
    def generate_result(x,y)
        id=@board[y][x]
        @result_pentomino=[]
        @result_board=Array.new(@n){Array.new(@n,0)}
        generate_result_core(x,y,id)
        raise "something is wrong" unless @result_pentomino.size==5
        @result_pentomino=normalize_polyomino(@result_pentomino)
        return @result_pentomino
    end
    def generate_result_core(x,y,id)
        return unless @result_board[y][x]==0 and @board[y][x]==id
        @result_pentomino << [x,y]
        @result_board[y][x]=1
        generate_result_core( x+1, y,id) if x<@n-1
        generate_result_core( x-1, y,id) if x>0
        generate_result_core( x, y+1,id) if y<@n-1
        generate_result_core( x, y-1,id) if y>0
    end
end
class Pentomino
    attr_reader :arr_xy_to_type
    def rot90(arr_xy)
        return normalize_polyomino(arr_xy.map{|e|[-e[1],e[0]]})
    end
    def flip(arr_xy)
        return normalize_polyomino(arr_xy.map{|e|[-e[0],e[1]]})
    end
    def initialize
        types={
            F:[[0,1],[1,0],[1,1],[1,2],[2,0]],
            I:[[0,0],[1,0],[2,0],[3,0],[4,0]],
            L:[[0,0],[1,0],[2,0],[3,0],[3,1]],
            N:[[0,0],[1,0],[1,1],[2,1],[3,1]],
            P:[[0,0],[0,1],[0,2],[1,0],[1,1]],
            T:[[0,0],[1,0],[1,1],[1,2],[2,0]],
            U:[[0,0],[0,1],[1,1],[2,1],[2,0]],
            V:[[0,0],[1,0],[2,0],[2,1],[2,2]],
            W:[[0,0],[1,0],[1,1],[2,1],[2,2]],
            X:[[0,1],[1,0],[1,1],[1,2],[2,1]],
            Y:[[0,0],[1,0],[2,0],[2,1],[3,0]],
            Z:[[0,0],[1,0],[1,1],[1,2],[2,2]],
        }
        @arr_xy_to_type={}
        types.each{|k,v| 
        #    puts k
        #    b=Array.new(5){Array.new(5,0)}
        #    v.each{|xy| b[xy[1]][xy[0]]=1}
        #    puts board_str(b)
            v=normalize_polyomino(v)
            @arr_xy_to_type[v]=k
            @arr_xy_to_type[rot90(v)]=k
            @arr_xy_to_type[rot90(rot90(v))]=k
            @arr_xy_to_type[rot90(rot90(rot90(v)))]=k
            v=flip(v)
            @arr_xy_to_type[v]=k
            @arr_xy_to_type[rot90(v)]=k
            @arr_xy_to_type[rot90(rot90(v))]=k
            @arr_xy_to_type[rot90(rot90(rot90(v)))]=k
        }
        #p @arr_xy_to_type.size
        #p @arr_xy_to_type.values.sort        
    end
end

def board_str(board)
    return board.map{|row| row.join(",")}.join("\n")
end

def normalize_polyomino(arr_xy)
    min_x=arr_xy.map{|e|e[0]}.min
    min_y=arr_xy.map{|e|e[1]}.min
    return arr_xy
        .map!{|e|[e[0]-min_x,e[1]-min_y]}
        .sort!{|e1,e2| (5*e1[0]+e1[1])<=>(5*e2[0]+e2[1])}
end

pen=Pentomino.new()
puts "set,n,type,count"
SetN=9000
SetN.times{|set|
    [4,16,64,256,1024].each{|n|
    STDERR.print n
        histogram={}
        ((5+1)..((5-1)*4+1)).each{|i| histogram[("reset#{i}").to_s]=0}
        pen.arr_xy_to_type.values.uniq.each{|type| histogram[type]=0}
        cnt_arr=[]
        (1000).times{|t|
            cnt,res= RandomPentomino.new(n).result
            cnt_arr<<cnt
            if res.size==1 then
                histogram[("reset#{res[0]}").to_s]+=1
            else
                histogram[pen.arr_xy_to_type[res]]+=1
            end
            STDERR.print "*" if t%100==1 
        }
        puts histogram.to_a.map{|e| "#{set},#{n},#{e[0]},#{e[1]}"}.join("\n")
        puts "#{set},#{n},count_average,#{cnt_arr.sum.to_f/(cnt_arr.size)}"
        puts "#{set},#{n},count_min,#{cnt_arr.min}"
        puts "#{set},#{n},count_max,#{cnt_arr.max}"
        STDOUT.flush
        STDERR.puts    
    }
    STDERR.puts("#{set}/#{SetN}")
}

=begin

$ time ruby random_pentomino.rb > out.csv
real    7m52.562s
user    7m50.252s
sys     0m2.169s

$ time seq 5 | xargs -t -I{} -P5 -n1 sh -c 'ruby random_pentomino.rb >out_{}.csv'
real    11m19.744s
user    55m42.967s
sys     0m10.523s

=end
