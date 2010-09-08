require 'test/unit'
require 'activefixture'
class ActivefixtureTest < Test::Unit::TestCase
  # Replace this with your real tests.
  def test_dfs_postorder_traversal
    n1 = ActiveFixture::Node.new( 1 )
    n2 = ActiveFixture::Node.new( 2 )
    n3 = ActiveFixture::Node.new( 3 )
    n4 = ActiveFixture::Node.new( 4 )
    n5 = ActiveFixture::Node.new( 5 )
    n1.add_edge( ActiveFixture::Edge.new( n1, n2 ) )
    n2.add_edge( ActiveFixture::Edge.new( n2, n5 ) )
    n2.add_adge( ActiveFixture::Edge.new( n2, n3 ) )
    n3.add_edge( ActiveFixture::Edge.new( n3, n5 ) )
    n4.add_edge( ActiveFixture::Edge.new( n4, n5 ) )
    
    #
    # 1 --> 2 ---> 5 <--- 4
    #       |      ^
    #       v      |
    #       3 -----+
    #
    
    dfs = ActiveFixture::DFSTraversal.new()
    result = dfs.post_order_traverse( n1 )
    assert result.index( n4 ) == 0
    assert result.index( n5 ) == 1
    assert result.index( n3 ) == 2
    assert result.index( n2 ) == 3
    assert result.index( n1 ) == 4
  end
end
