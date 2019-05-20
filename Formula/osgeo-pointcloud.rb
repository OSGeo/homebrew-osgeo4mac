class OsgeoPointcloud < Formula
  desc "PostgreSQL extension for storing point cloud (LIDAR) data"
  homepage "https://github.com/pgpointcloud/pointcloud"
  url "https://github.com/pgpointcloud/pointcloud/archive/v1.2.0.tar.gz"
  sha256 "8542a4c714b4d0c67f10d092291a43b5650871b4ec8caf831e492810f25bb93c"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "0441c0f8dafa1e14e132feedecf64d587dd9f676517199a78f7c633d32c05da1" => :mojave
    sha256 "0441c0f8dafa1e14e132feedecf64d587dd9f676517199a78f7c633d32c05da1" => :high_sierra
    sha256 "39acb394587990363e8495770479e91af9f13edf5bcf157905c0762e667c24e3" => :sierra
  end

  # url "https://github.com/pgpointcloud/pointcloud/archive/v1.0.1.tar.gz"
  # sha256 "3fac2efe1263b0876c26fc77e28f3664b56aa1e142c92383f9eb5b828999d0e7"

  revision 2

  head "https://github.com/pgpointcloud/pointcloud.git", :branch => "master"

  # for v1.0.1
  # pc_access.c:318:46: error: AggState v1.0.1
  # it was decided to use the updated lines from master
  # https://github.com/pgpointcloud/pointcloud/issues/174
  # patch :DATA

  # depends_on "cmake" => :build # for v1.0.1

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "libxml2"
  depends_on "osgeo-libght"
  depends_on "osgeo-laz-perf" # => :optional

  depends_on "cunit" # if build.with? "test"

  depends_on "llvm" => :build

  if build.with?("postgresql10")
    depends_on "osgeo-postgresql@10"
  else
    depends_on "osgeo-postgresql"
  end

  # Fix boolean case errors when compiling againt pg11
  # https://github.com/pgpointcloud/pointcloud/pull/237
  patch do
    url "https://patch-diff.githubusercontent.com/raw/pgpointcloud/pointcloud/pull/237.diff"
    sha256 "72b542ec7c8ad3a61186e5fb24e6555df3998361ee5f4a75034b61db514f16df"
  end

  def install
    if build.with?("postgresql10")
      args = "--with-pgconfig=#{Formula["osgeo-postgresql@10"].opt_bin}/pg_config"
    else
      args = "--with-pgconfig=#{Formula["osgeo-postgresql"].opt_bin}/pg_config"
    end

    mkdir lib/"postgresql"
    mkdir_p pkgshare/"postgresql/extension/"

    # for v1.0.1
    # inreplace "pgsql/CMakeLists.txt", "${PGSQL_PKGLIBDIR}", "#{lib}/postgresql"
    # inreplace "pgsql/CMakeLists.txt", "${PGSQL_SHAREDIR}", "#{share}/postgresql"
    # inreplace "pgsql_postgis/CMakeLists.txt", "${PGSQL_SHAREDIR}", "#{share}/postgresql

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--with-lazperf=#{Formula["osgeo-laz-perf"].opt_prefix}", *args
    system "make"
    # system "make", "install"
    (lib/"postgresql").mkpath
    (share/"postgresql/extension").mkpath
    cp_r "#{buildpath}/pgsql/pointcloud-1.2.so", "#{lib}/postgresql/"
    # ln_s "#{lib}/postgresql/pointcloud-1.2.so", "#{lib}/postgresql/pointcloud.so"
    cp_r "#{buildpath}/pgsql/pointcloud--1.2.0.sql", "#{share}/postgresql/extension/"
    cp_r "#{buildpath}/pgsql/pointcloud.control", "#{share}/postgresql/extension/"
    cp_r "#{buildpath}/pgsql/pointcloud--1.1.0--1.2.0.sql", "#{share}/postgresql/extension/"
    cp_r "#{buildpath}/pgsql/pointcloud--1.1.1--1.2.0.sql", "#{share}/postgresql/extension/"
    cp_r "#{buildpath}/pgsql/pointcloud--1.2.0--1.2.0next.sql", "#{share}/postgresql/extension/"
    cp_r "#{buildpath}/pgsql/pointcloud--1.2.0next--1.2.0.sql", "#{share}/postgresql/extension/"
    cp_r "#{buildpath}/pgsql_postgis/pointcloud_postgis--1.2.0.sql", "#{share}/postgresql/extension/"
    cp_r "#{buildpath}/pgsql_postgis/pointcloud_postgis.control", "#{share}/postgresql/extension/"

    # nothing is installed here?
    rm_r "#{share}/osgeo-pointcloud"

    # for v1.0.1
    # mkdir "build" do
    #   system "cmake", "..", "-DCMAKE_PREFIX_PATH=#{Formula["osgeo-postgresql"].opt_prefix}", *std_cmake_args
    #   system "make"
    #   # system "/usr/local/bin/bbedit", "CMakeCache.txt"
    #   # raise
    #   # TODO: this fails with Segmentation fault: 11
    #   # puts `lib/cunit/cu_tester` if build.with? "test"
    #   system "make", "install"
    # end
  end

  test do
    system "True"
  end
end

__END__

--- a/pgsql/pc_access.c
+++ b/pgsql/pc_access.c
@@ -310,18 +310,10 @@

 	if (arg1_typeid == InvalidOid)
 		ereport(ERROR,
-		        (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
-		         errmsg("could not determine input data type")));
-
-	if (fcinfo->context && IsA(fcinfo->context, AggState))
-	{
-		aggcontext = ((AggState *) fcinfo->context)->aggcontext;
-	}
-	else if (fcinfo->context && IsA(fcinfo->context, WindowAggState))
-	{
-		aggcontext = ((WindowAggState *) fcinfo->context)->aggcontext;
-	}
-	else
+			(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
+			errmsg("could not determine input data type")));
+
+	if ( ! AggCheckCallContext(fcinfo, &aggcontext) )
 	{
 		/* cannot be called directly because of dummy-type argument */
 		elog(ERROR, "pointcloud_agg_transfn called in non-aggregate context");
@@ -551,9 +543,9 @@

 	if ( pc_bounds_intersects(&(serpa1->bounds), &(serpa2->bounds)) )
 	{
-		PG_RETURN_BOOL(TRUE);
-	}
-	PG_RETURN_BOOL(FALSE);
+		PG_RETURN_BOOL(true);
+	}
+	PG_RETURN_BOOL(false);
 }

 PG_FUNCTION_INFO_V1(pcpatch_size);

--- a/pgsql/pc_inout.c
+++ b/pgsql/pc_inout.c
@@ -171,7 +171,7 @@

 	if ( ! err )
 	{
-		PG_RETURN_BOOL(FALSE);
+		PG_RETURN_BOOL(false);
 	}

 	valid = pc_schema_is_valid(schema);
