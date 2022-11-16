import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ExploreTopicPage(),
    );
  }
}

class ExploreTopicPage extends StatefulWidget {



  const ExploreTopicPage({Key? key}) : super(key: key);

  @override
  State<ExploreTopicPage> createState() => _ExploreTopicPageState();
}

class _ExploreTopicPageState extends State<ExploreTopicPage>{
  TabController? tabController;
  double scrollOffset = 0;  //pixels scroll offset
  bool showSmallTitle = false;  //whether to show the title in the appbar
  double headerHeight = 300;  //initial height to allow space to render and measure the height of the html introduction
  final headerImageHeight = 200.0; //rive/image banner height, stored as used as part of several calculations
  final ScrollController _scrollController = ScrollController(); //scroll controller used for calculating title and rive scroll positions
  SMIInput<double>? _riveScroll;  //the input for rive (a number ranging from 0-100) to control how much the image parallax effect scrolls
  SMIInput<double>? _riveColourMode;
  String bannerImageUrl = 'https://dev-cdn-v4-cms.mypossibleself.com/sleep_banner_lightmode_test_2_e3c2c36c35.riv';
  bool isMeasured = false;  //marker for when html intro is measured
  double titleChangeScrollOffset = 60;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _riveScroll?.value = getScrollAmount(_scrollController.offset);
      scrollOffset = _scrollController.offset;

      //keep track of whether to show the small title as making this check every scroll causes performance issues
      if (showSmallTitle==false&&scrollOffset>titleChangeScrollOffset){
        setState(() {
          showSmallTitle = true;
        });
      }
      else if (showSmallTitle==true&&scrollOffset<=titleChangeScrollOffset){
        setState(() {
          showSmallTitle = false;
        });
      }

    });
  }

  double getScrollAmount(double scrollOffset){
    double oldRange = (headerHeight - 0);
    double newRange = (100 - 0);
    double newValue = ((((scrollOffset - 0) * newRange) / oldRange) + 0).clamp(0, 100);
    return newValue;
  }


  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 1, // This is the number of tabs.
      initialIndex: 0,
      //animationDuration: Duration.zero, // disabling the animation of the tabs fixes redraw issue, redrawing whilst animating tab keeps tab empty??
      child: Builder(
          builder: (context) {
            return Scaffold(
              // floatingActionButton: FloatingActionButton.extended(onPressed: (){}, label: Text('Filter'),),
              // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              backgroundColor: const Color(0xffffffff),
              body: NestedScrollView(
                controller: _scrollController,

                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  // These are the slivers that show up in the "outer" scroll view.
                  return <Widget>[
                    SliverOverlapAbsorber(
                      // This widget takes the overlapping behavior of the SliverAppBar,
                      // and redirects it to the SliverOverlapInjector below. If it is
                      // missing, then it is possible for the nested "inner" scroll view
                      // below to end up under the SliverAppBar even when the inner
                      // scroll view thinks it has not been scrolled.
                      // This is not necessary if the "headerSliverBuilder" only builds
                      // widgets that do not overlap the next sliver.
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverAppBar(
                        title: AnimatedOpacity(
                            opacity: showSmallTitle ? 1 : 0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                            child: const Text('Small Title')),
                        // This is the title in the app bar.
                        pinned: true,
                        elevation: 0,
                        backgroundColor: const Color(0xffffffff),
                        flexibleSpace: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                          return Stack(
                            children: [
                              SizedBox(
                                height: headerImageHeight,
                                child: Stack(
                                  children: [

                                      Stack(
                                        children: [
                                          RepaintBoundary(
                                            child:
                                            RiveAnimation.network(
                                              bannerImageUrl,
                                              fit: BoxFit.none,
                                              onInit: _onRiveInit,

                                              // stateMachines: const ['button'],
                                              placeHolder: const Center(child: SizedBox()),
                                            ),
                                          ),
                                        ],
                                      ),
                                    Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 20.0, bottom: 25),
                                          child: AnimatedOpacity(
                                            duration: const Duration(milliseconds: 150),
                                            opacity: scrollOffset > titleChangeScrollOffset ? 0 : 1,
                                            curve: Curves.easeIn,
                                            child: Transform.translate(
                                              offset: Offset(0, scrollOffset * -1),
                                              child: const Text('Large title', style: TextStyle(color: Colors.white, fontSize: 36),),
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: headerImageHeight - scrollOffset < 0 ? 0 : headerImageHeight - scrollOffset,
                                  ), //don't try and create a sized box less than 0 height
                                  AnimatedOpacity(
                                      duration: const Duration(milliseconds: 500),
                                      opacity: scrollOffset > (titleChangeScrollOffset+10) ? 0 : 1,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                                        child: Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit. In nec placerat nunc. Morbi id nulla vitae quam consequat auctor. ', ), //value.topic.introHtmlText
                                      )),
                                ],
                              ),
                              Positioned(
                                  bottom: 1,
                                  left: 0,
                                  right: 0,
                                  child: Container(height: 1, color: Colors.white24, )),

                            ],
                          );
                        }),
                        expandedHeight: headerHeight,
                        // The "forceElevated" property causes the SliverAppBar to show
                        // a shadow. The "innerBoxIsScrolled" parameter is true when the
                        // inner scroll view is scrolled beyond its "zero" point, i.e.
                        // when it appears to be scrolled below the SliverAppBar.
                        // Without this, there are cases where the shadow would appear
                        // or not appear inappropriately, because the SliverAppBar is
                        // not actually aware of the precise position of the inner
                        // scroll views.
                        forceElevated: innerBoxIsScrolled,
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  // These are the contents of the tab views, below the tabs.
                  children: [

                SafeArea(
                key: const ValueKey("1-tabview"),
                top: false,
                bottom: false,
                child: Builder(
                  // This Builder is needed to provide a BuildContext that is
                  // "inside" the NestedScrollView, so that
                  // sliverOverlapAbsorberHandleFor() can find the
                  // NestedScrollView.
                  builder: (BuildContext context) {
                    // print('${NestedScrollView.sliverOverlapAbsorberHandleFor(context).layoutExtent} layoutextent');
                    // print('${NestedScrollView.sliverOverlapAbsorberHandleFor(context).scrollExtent} scrollextent');

                    return CustomScrollView(
                      // The "controller" and "primary" members should be left
                      // unset, so that the NestedScrollView can control this
                      // inner scroll view.
                      // If the "controller" property is set, then this scroll
                      // view will not be associated with the NestedScrollView.
                      // The PageStorageKey should be unique to this ScrollView;
                      // it allows the list to remember its scroll position when
                      // the tab view is not on the screen.
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      key: const PageStorageKey<String>("1-page"),
                      slivers: <Widget>[
                        SliverOverlapInjector(
                          // This is the flip side of the SliverOverlapAbsorber
                          // above.
                          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                // This builder is called for each child.
                                // In this example, we just number each list item.
                                return Text('Nothing to see here for index $index');
                              },
                              // The childCount of the SliverChildBuilderDelegate
                              // specifies how many children this inner list
                              // has. In this example, each tab has a list of
                              // a 30, but this is arbitrary.
                              childCount: 1,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )

              ],
                ),
              ),
            );
          }
      ),
    );
  }

  void _onRiveInit(Artboard artboard) async {
    var riveController = StateMachineController.fromArtboard(
      artboard,
      'state_machine',
    );
    print('rive init complete');

    if (riveController != null) {
      print('rive controller not null');
      artboard.addController(riveController);
      _riveScroll = riveController.findInput('scroll');
      print('rive scroll ${_riveScroll?.value} $_riveScroll');
      _riveColourMode = riveController.findInput('colour_mode');
    }

    if (_riveColourMode!=null) {
      _riveColourMode!.value = 2;
    }

  }


}







