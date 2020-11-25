import 'package:weather_app/blocs/weather_bloc.dart';
import 'package:weather_app/models/weather_response.dart';
import 'package:weather_app/networking/api_response.dart';
import 'package:weather_app/view/address_search.dart';
import 'package:weather_app/models/place_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  WeatherBloc _bloc;
  List<String> cities = new List<String>();
  AnimationController cloudyController;
  Animation sizeCloudAnimation;
  AnimationController sunnyController;
  AnimationController snowController;
  Animation<Offset> _offsetFirstAnimation;
  Animation<Offset> _offsetSecondAnimation;
  Animation<Offset> _offsetThirdAnimation;
  var val = false;

  @override
  void initState() {
    super.initState();
    _bloc = WeatherBloc();

    cloudyController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    sizeCloudAnimation =
        Tween<double>(begin: 40.0, end: 45.0).animate(cloudyController);

    cloudyController.addListener(() {
      setState(() {});
    });

    cloudyController.repeat(reverse: true);

    sunnyController = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: Duration(seconds: 2),
    )..repeat();

    snowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _offsetFirstAnimation = Tween<Offset>(
      begin: Offset(-0.5, 0.5),
      end: const Offset(0.5, 1.7),
    ).animate(CurvedAnimation(
      parent: snowController,
      curve: Curves.slowMiddle,
    ));
    _offsetSecondAnimation = Tween<Offset>(
      begin: Offset(1.5, -0.5),
      end: const Offset(0.5, 0.7),
    ).animate(CurvedAnimation(
      parent: snowController,
      curve: Curves.slowMiddle,
    ));
    _offsetThirdAnimation = Tween<Offset>(
      begin: Offset(0.5, 0.5),
      end: Offset(0.5, -0.3),
    ).animate(CurvedAnimation(
      parent: snowController,
      curve: Curves.slowMiddle,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          'Weather',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return _bloc.refreshWeathers();
        },
        child: StreamBuilder<ApiResponse<List<Weather>>>(
          stream: _bloc.weatherListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  final newList = snapshot.data.data;
                  return WeatherList(
                    weatherList: newList,
                    sizeAnimation: sizeCloudAnimation,
                    builtSun: _buildSun(),
                    offSetFirstAnimation: _offsetFirstAnimation,
                    offSetSecondAnimation: _offsetSecondAnimation,
                    offSetThirdAnimation: _offsetThirdAnimation,
                  );
                  break;
                case Status.ERROR:
                  return Error(
                      errorMessage: snapshot.data.message,
                      onRetryPressed: () => setState(() {
                            _bloc.clearWeather();
                            _bloc.updateWeathers();
                          }));
                  break;
              }
            }
            return Container();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Suggestion result = await showSearch(
            context: context,
            delegate: AddressSearch(),
          );
          if (result != null) {
            setState(() {
              _bloc.addPlace(result.name);
              _bloc.fetchWeatherList();
              _bloc.clearWeather();
            });
          }
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSun() {
    return AnimatedBuilder(
      animation:
          CurvedAnimation(parent: sunnyController, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildContainer(40 * sunnyController.value),
            _buildContainer(50 * sunnyController.value),
            _buildContainer(60 * sunnyController.value),
            Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFFDB813),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (val ? Colors.amber[100] : Colors.orangeAccent)
            .withOpacity(1 - sunnyController.value),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class WeatherList extends StatelessWidget {
  final List<Weather> weatherList;
  final Animation sizeAnimation;
  final Animation offSetFirstAnimation;
  final Animation offSetSecondAnimation;
  final Animation offSetThirdAnimation;
  final Widget builtSun;

  const WeatherList(
      {Key key,
      this.weatherList,
      this.sizeAnimation,
      this.builtSun,
      this.offSetFirstAnimation,
      this.offSetSecondAnimation,
      this.offSetThirdAnimation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: weatherList.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Row(children: <Widget>[
                      Expanded(
                          child: Column(children: <Widget>[
                        Text('${weatherList[index].cityName.toString() ?? ""}',
                            textAlign: TextAlign.center),
                      ])),
                      Expanded(
                          child: Column(children: <Widget>[
                        if (weatherList[index].maxTempFirstDay >= 0 &&
                            weatherList[index].maxTempFirstDay <= 10)
                          SizedBox(
                              height: 50,
                              child: Container(
                                height: sizeAnimation.value,
                                width: sizeAnimation.value,
                                child: Image.asset('assets/images/cloud.png'),
                              )),
                        if (weatherList[index].maxTempFirstDay > 10)
                          SizedBox(
                              height: 50,
                              child: Container(
                                child: builtSun,
                              )),
                            if (weatherList[index].maxTempFirstDay < 0)
                              SizedBox(
                                  height: 60,
                                  child: Column(children: <Widget>[
                                    SlideTransition(
                                      position: offSetFirstAnimation,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        child: Image.asset(
                                            'assets/images/snowflake.png'),
                                      ),
                                    ),
                                    SlideTransition(
                                      position: offSetSecondAnimation,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        child: Image.asset(
                                            'assets/images/snowflake.png'),
                                      ),
                                    ),
                                    SlideTransition(
                                      position: offSetThirdAnimation,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        child: Image.asset(
                                            'assets/images/snowflake.png'),
                                      ),
                                    )
                                  ])),
                        Text(
                            '${weatherList[index].maxTempFirstDay.toString() + "°C" ?? ""}',
                            textAlign: TextAlign.center),
                      ])),
                      Expanded(
                          child: Column(children: <Widget>[
                        if (weatherList[index].maxTempSecondDay >= 0 &&
                            weatherList[index].maxTempSecondDay <= 10)
                          SizedBox(
                              height: 50,
                              child: Container(
                                height: sizeAnimation.value,
                                width: sizeAnimation.value,
                                child: Image.asset('assets/images/cloud.png'),
                              )),
                        if (weatherList[index].maxTempSecondDay > 10)
                          SizedBox(
                              height: 50,
                              child: Container(
                                child: builtSun,
                              )),
                            if (weatherList[index].maxTempSecondDay < 0)
                              SizedBox(
                                  height: 60,
                                  child: Column(children: <Widget>[
                                    SlideTransition(
                                      position: offSetFirstAnimation,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        child: Image.asset(
                                            'assets/images/snowflake.png'),
                                      ),
                                    ),
                                    SlideTransition(
                                      position: offSetSecondAnimation,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        child: Image.asset(
                                            'assets/images/snowflake.png'),
                                      ),
                                    ),
                                    SlideTransition(
                                      position: offSetThirdAnimation,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        child: Image.asset(
                                            'assets/images/snowflake.png'),
                                      ),
                                    )
                                  ])),
                        Text(
                            '${weatherList[index].maxTempSecondDay.toString() + "°C" ?? ""}',
                            textAlign: TextAlign.center),
                      ])),
                      Expanded(
                          child: Column(children: <Widget>[
                        if (weatherList[index].maxTempThirdDay >= 0 &&
                            weatherList[index].maxTempThirdDay <= 10)
                          SizedBox(
                              height: 50,
                              child: Container(
                                height: sizeAnimation.value,
                                width: sizeAnimation.value,
                                child: Image.asset('assets/images/cloud.png'),
                              )),
                        if (weatherList[index].maxTempThirdDay > 10)
                          SizedBox(
                              height: 50,
                              child: Container(
                                child: builtSun,
                              )),
                        if (weatherList[index].maxTempThirdDay < 0)
                          SizedBox(
                              height: 60,
                              child: Column(children: <Widget>[
                                SlideTransition(
                                  position: offSetFirstAnimation,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    child: Image.asset(
                                        'assets/images/snowflake.png'),
                                  ),
                                ),
                                SlideTransition(
                                  position: offSetSecondAnimation,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    child: Image.asset(
                                        'assets/images/snowflake.png'),
                                  ),
                                ),
                                SlideTransition(
                                  position: offSetThirdAnimation,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    child: Image.asset(
                                        'assets/images/snowflake.png'),
                                  ),
                                )
                              ])),
                        Text(
                            '${weatherList[index].maxTempThirdDay.toString() + "°C" ?? ""}',
                            textAlign: TextAlign.center),
                      ])),
                    ]),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class Error extends StatelessWidget {
  final String errorMessage;

  final Function onRetryPressed;

  const Error({Key key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Oops, something wen wrong!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          RaisedButton(
            color: Colors.redAccent,
            child: Text(
              'Retry',
              style: TextStyle(),
            ),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  final String loadingMessage;

  const Loading({Key key, this.loadingMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
          ),
        ],
      ),
    );
  }
}
