import 'package:flutter/material.dart';

const accessKey = "1C8XW3wpxKx2e8mj7AciEVqhZN3mljMtSgxxxzxc_-0";
const secretKey = "K1xF8TZQGWmmyZZAC3QHpJ_Wv0TFwTXcoLxAYbPccgk";
const quotesApiKey = "ixgrcVjoj57P/5zFQfrAjw==e6XsvXZJpi76mYuJ";

late Size mq;

void initMediaQuery(BuildContext context) {
  mq = MediaQuery.of(context).size;
}

var kQuoteTextStyle = TextStyle(
  fontSize: 25,
  color: Colors.white.withOpacity(0.95),
  fontWeight: FontWeight.w600,
);

var kAuthorTextStyle = TextStyle(
  fontSize: 20,
  color: Colors.white.withOpacity(0.5),
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
);